-- Rode este SQL no Supabase SQL Editor para criar pedido e baixar estoque
-- em uma unica transacao segura.

create or replace function public.create_order_with_stock(
  p_items jsonb,
  p_payment_method text,
  p_total_amount numeric,
  p_delivery_address text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_order public.orders%rowtype;
  v_item jsonb;
  v_product public.products%rowtype;
  v_product_id bigint;
  v_quantity integer;
  v_product_name text;
  v_unit_price numeric(10, 2);
  v_items_result jsonb := '[]'::jsonb;
begin
  if v_user_id is null then
    raise exception 'Entre com sua conta para finalizar o pedido.';
  end if;

  if p_items is null
    or jsonb_typeof(p_items) <> 'array'
    or jsonb_array_length(p_items) = 0 then
    raise exception 'O pedido precisa ter pelo menos um produto.';
  end if;

  if p_payment_method not in ('pix', 'cash_on_delivery', 'card_on_delivery') then
    raise exception 'Forma de pagamento invalida.';
  end if;

  insert into public.orders (
    user_id,
    status,
    payment_method,
    total_amount,
    delivery_address
  )
  values (
    v_user_id,
    'pending',
    p_payment_method,
    p_total_amount,
    p_delivery_address
  )
  returning * into v_order;

  for v_item in
    select value from jsonb_array_elements(p_items)
  loop
    v_product_id := nullif(v_item ->> 'product_id', '')::bigint;
    v_quantity := coalesce(nullif(v_item ->> 'quantity', '')::integer, 0);

    if v_product_id is null then
      raise exception 'Produto invalido no pedido.';
    end if;

    if v_quantity <= 0 then
      raise exception 'Quantidade invalida no pedido.';
    end if;

    select *
    into v_product
    from public.products
    where id = v_product_id
      and is_active = true
    for update;

    if not found then
      raise exception 'Produto nao encontrado ou inativo.';
    end if;

    if v_product.stock_quantity < v_quantity then
      raise exception 'Estoque insuficiente para %. Disponivel: %.',
        v_product.name,
        v_product.stock_quantity;
    end if;

    v_product_name := coalesce(nullif(v_item ->> 'product_name', ''), v_product.name);
    v_unit_price := coalesce(
      nullif(v_item ->> 'unit_price', '')::numeric,
      v_product.price
    );

    update public.products
    set stock_quantity = stock_quantity - v_quantity
    where id = v_product.id;

    insert into public.order_items (
      order_id,
      product_id,
      product_name,
      unit_price,
      quantity
    )
    values (
      v_order.id,
      v_product.id,
      v_product_name,
      v_unit_price,
      v_quantity
    );

    v_items_result := v_items_result || jsonb_build_array(
      jsonb_build_object(
        'product_id', v_product.id,
        'product_name', v_product_name,
        'product_image_url', coalesce(v_product.image_url, ''),
        'unit_price', v_unit_price,
        'quantity', v_quantity
      )
    );
  end loop;

  return jsonb_build_object(
    'id', v_order.id,
    'user_id', v_order.user_id,
    'status', v_order.status,
    'payment_method', v_order.payment_method,
    'total_amount', v_order.total_amount,
    'delivery_address', v_order.delivery_address,
    'created_at', v_order.created_at,
    'order_items', v_items_result
  );
end;
$$;

revoke all on function public.create_order_with_stock(
  jsonb,
  text,
  numeric,
  text
) from public;

grant execute on function public.create_order_with_stock(
  jsonb,
  text,
  numeric,
  text
) to authenticated;
