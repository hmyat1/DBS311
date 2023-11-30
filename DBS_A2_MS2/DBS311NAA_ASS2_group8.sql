//Group 8
//Names: Jeevanjot khehra , Arashdeep singh , Hla Myint Myat

SET SERVEROUTPUT ON;

--finding customers with a customerID

CREATE OR REPLACE PROCEDURE find_customer(customerID IN NUMBER, found OUT NUMBER) AS
BEGIN
    found := 0;
    SELECT COUNT(*)
    INTO found
    FROM customers
    WHERE CUSTOMER_ID = customerID;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            found := 0;
END;
/

--finding a product with productID

CREATE OR REPLACE PROCEDURE find_product(productID IN NUMBER, price OUT products.list_price%TYPE, productName OUT products.product_name%TYPE) AS
BEGIN
    price := 0;
    productName := NULL;
    
    SELECT product_name, list_price
    INTO productName, price
    FROM products
    WHERE product_id = productID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            price := 0;
END;
/

--adding a new order for a customer

CREATE OR REPLACE PROCEDURE add_order(customerID IN NUMBER, new_order_id OUT NUMBER) AS
BEGIN
    SELECT  MAX(order_id)
    INTO    new_order_id
    FROM    orders;   
    new_order_id := new_order_id + 1;  
    INSERT INTO orders
    (ORDER_ID, CUSTOMER_ID, STATUS, SALESMAN_ID, ORDER_DATE)
    VALUES
    (new_order_id, customerID, 'Shipped', 56, SYSDATE);
END;
/

--generating order id 

CREATE OR REPLACE FUNCTION generate_order_id RETURN NUMBER IS
    new_order_id NUMBER;
BEGIN
    SELECT MAX(order_id) + 1
    INTO new_order_id
    FROM orders;
    
    RETURN new_order_id;
END generate_order_id;
/


--adding an order to order item list
CREATE OR REPLACE PROCEDURE add_order_item(orderId IN order_items.order_id%TYPE,
                                            itemId IN order_items.item_id%TYPE,
                                            productId IN order_items.product_id%TYPE,
                                            inQuantity IN order_items.quantity%TYPE,
                                            price IN order_items.unit_price%TYPE) AS
BEGIN
    INSERT INTO order_items
    (order_id, item_id, product_id, quantity, unit_price)
    VALUES
    (orderId, itemId, productId, inQuantity, price);
END;
/

-- customer_order procedure
CREATE OR REPLACE PROCEDURE customer_order(
    customerId IN NUMBER, 
    orderId IN OUT NUMBER
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM orders
    WHERE customer_id = customerId AND order_id = orderId;

    IF v_count = 0 THEN
        orderId := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        orderId := 0; -- In case of any exception, consider as no order found
END customer_order;
/

--display_order_status Procedure
CREATE OR REPLACE PROCEDURE display_order_status(
    orderId IN NUMBER, 
    status OUT orders.status%TYPE
) AS
BEGIN
    SELECT status
    INTO status
    FROM orders
    WHERE order_id = orderId;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            status := NULL;
END display_order_status;
/

--cancel_order Procedure
CREATE OR REPLACE PROCEDURE cancel_order(
    orderId IN NUMBER, 
    cancelStatus OUT NUMBER
) AS
    v_orderStatus orders.status%TYPE;
BEGIN
    SELECT status
    INTO v_orderStatus
    FROM orders
    WHERE order_id = orderId;

    IF v_orderStatus = 'Canceled' THEN
        cancelStatus := 1; -- Already canceled
    ELSIF v_orderStatus = 'Shipped' THEN
        cancelStatus := 2; -- Cannot be canceled
    ELSE
        UPDATE orders
        SET status = 'Canceled'
        WHERE order_id = orderId;
        cancelStatus := 3; -- Successfully canceled
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        cancelStatus := 0; -- Order does not exist
END cancel_order;
/















