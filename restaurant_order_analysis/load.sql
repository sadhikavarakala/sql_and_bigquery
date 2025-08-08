-- menu items
CREATE TABLE public.menu_items (
  menu_item_id  integer PRIMARY KEY,
  item_name     text NOT NULL,
  category      text,
  price         numeric(10,2) CHECK (price >= 0)
);

-- order details
CREATE TABLE public.order_details (
  order_details_id integer PRIMARY KEY,
  order_id         integer NOT NULL,
  order_date       date,                      -- from MM/DD/YY
  order_time       time without time zone,    -- from HH:MM:SS AM/PM
  item_id          integer REFERENCES public.menu_items(menu_item_id)
);

-- menu items data load
\copy public.menu_items (menu_item_id, item_name, category, price) 
FROM '/Users/sadhikavarakala/GitHub/sql/sql_and_bigquery/Restaurant+Orders+CSV/menu_items.csv' 
WITH (FORMAT csv, HEADER true)

-- order details data load
\copy public.order_details (order_details_id, order_id, order_date, order_time, item_id) 
FROM '/Users/sadhikavarakala/GitHub/sql/sql_and_bigquery/Restaurant+Orders+CSV/order_details.csv' 
WITH (FORMAT csv, HEADER true, NULL 'NULL')