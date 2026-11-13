DROP TABLE IF EXISTS products_changed;

CREATE TABLE products (
	product_id	VARCHAR(10) PRIMARY KEY,
    product_name	VARCHAR(100) NOT NULL,
    category	VARCHAR(50) NOT NULL,
    sub_category	VARCHAR(50) NOT NULL,
    unit_cost	NUMERIC(10, 2) NOT NULL,
    selling_price	NUMERIC(10, 2) NOT NULL,
    shipping_cost	NUMERIC(10, 2) NOT NULL,
    weight_lbs	NUMERIC(6, 2) NOT NULL,
    supplier	VARCHAR(20) NOT NULL
);

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
	order_id            VARCHAR(15)     PRIMARY KEY,
    customer_id        	VARCHAR(10)     NOT NULL,
    order_date         	DATE            NOT NULL,
    sales_channel		VARCHAR(30)     NOT NULL,
    payment_method      VARCHAR(30)     NOT NULL,
    region              VARCHAR(20)     NOT NULL,
    items_ordered       SMALLINT        NOT NULL,
    primary_category    VARCHAR(30)     NOT NULL,
    gross_revenue       NUMERIC(12, 2)  NOT NULL,
    discount_pct        NUMERIC(5, 2)   NOT NULL DEFAULT 0,
    discount_amount     NUMERIC(12, 2)  NOT NULL DEFAULT 0,
    shipping_cost       NUMERIC(10, 2)  NOT NULL,
    product_cost        NUMERIC(12, 2)  NOT NULL,
    platform_fee        NUMERIC(10, 2)  NOT NULL DEFAULT 0,
    transaction_fee     NUMERIC(10, 2)  NOT NULL DEFAULT 0,
    returned            BOOLEAN         NOT NULL DEFAULT FALSE,
    refund_amount       NUMERIC(12, 2)  NOT NULL DEFAULT 0,
    net_revenue         NUMERIC(12, 2)  NOT NULL,
    total_costs         NUMERIC(12, 2)  NOT NULL,
    profit              NUMERIC(12, 2)  NOT NULL
);

DROP TABLE IF EXISTS marketing_spend;

CREATE TABLE marketing_spend (
    spend_date      VARCHAR(20),
    sales_channel   VARCHAR(50),
    region          VARCHAR(50),
    amount_spent    NUMERIC(12, 2),
    impressions     INTEGER,
    clicks          INTEGER,
    conversions     INTEGER,
    revenue			DOUBLE,
    cpc				DOUBLE,
    cpa				DOUBLE,
    roas			DOUBLE,
	id     			NUMERIC			PRIMARY KEY
);

CREATE INDEX idx_orders_date        ON orders (order_date);
CREATE INDEX idx_orders_channel     ON orders (sales_channel);
CREATE INDEX idx_orders_region      ON orders (region);
CREATE INDEX idx_orders_category    ON orders (primary_category);
CREATE INDEX idx_orders_customer    ON orders (customer_id);
CREATE INDEX idx_orders_returned    ON orders (returned);