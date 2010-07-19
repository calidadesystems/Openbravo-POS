--    Openbravo POS is a point of sales application designed for touch screens.
--    Copyright (C) 2007-2010 Openbravo, S.L.
--    http://sourceforge.net/projects/openbravopos
--
--    This file is part of Openbravo POS.
--
--    Openbravo POS is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Openbravo POS is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with Openbravo POS.  If not, see <http://www.gnu.org/licenses/>.

-- Database upgrade script for ORACLE
-- v2.10 - v2.20

CREATE TABLE TAXCUSTCATEGORIES (
    ID VARCHAR2(255) NOT NULL,
    NAME VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCUSTCAT_NAME_INX ON TAXCUSTCATEGORIES(NAME);

CREATE TABLE TAXCATEGORIES (
    ID VARCHAR2(255) NOT NULL,
    NAME VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCAT_NAME_INX ON TAXCATEGORIES(NAME);
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('000', 'Tax Exempt');
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('001', 'Tax Standard');
INSERT INTO TAXCATEGORIES (ID, NAME) SELECT ID, NAME FROM TAXES;

ALTER TABLE TAXES ADD CATEGORY VARCHAR2(255);
ALTER TABLE TAXES ADD CUSTCATEGORY VARCHAR2(255);
ALTER TABLE TAXES ADD PARENTID VARCHAR2(255);
ALTER TABLE TAXES ADD RATECASCADE NUMERIC(1);
ALTER TABLE TAXES ADD RATEORDER INTEGER;
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CAT_FK FOREIGN KEY (CATEGORY) REFERENCES TAXCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CUSTCAT_FK FOREIGN KEY (CUSTCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_TAXES_FK FOREIGN KEY (PARENTID) REFERENCES TAXES(ID);
UPDATE TAXES SET CATEGORY = ID, RATECASCADE = 0;
ALTER TABLE TAXES MODIFY CATEGORY VARCHAR2(255) NOT NULL;
ALTER TABLE TAXES MODIFY RATECASCADE NUMERIC(1) NOT NULL;

ALTER TABLE PRODUCTS ADD TAXCAT VARCHAR2(255);
ALTER TABLE PRODUCTS ADD CONSTRAINT PRODUCTS_TAXCAT_FK FOREIGN KEY (TAXCAT) REFERENCES TAXCATEGORIES(ID);
UPDATE PRODUCTS SET TAXCAT = TAX;
ALTER TABLE PRODUCTS MODIFY TAXCAT VARCHAR2(255) NOT NULL;
ALTER TABLE PRODUCTS DROP CONSTRAINT PRODUCTS_FK_2;
ALTER TABLE PRODUCTS DROP COLUMN TAX;

ALTER TABLE CUSTOMERS ADD SEARCHKEY VARCHAR2(255);
UPDATE CUSTOMERS SET SEARCHKEY = ID;
ALTER TABLE CUSTOMERS MODIFY SEARCHKEY VARCHAR2(255) NOT NULL;
CREATE UNIQUE INDEX CUSTOMERS_SKEY_INX ON CUSTOMERS(SEARCHKEY);

ALTER TABLE CUSTOMERS ADD ADDRESS2 VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD POSTAL VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD CITY VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD REGION VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD COUNTRY VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD FIRSTNAME VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD LASTNAME VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD EMAIL VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD PHONE VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD PHONE2 VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD FAX VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD TAXCATEGORY VARCHAR2(255);
ALTER TABLE CUSTOMERS ADD CONSTRAINT CUSTOMERS_TAXCAT FOREIGN KEY (TAXCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);

ALTER TABLE CLOSEDCASH ADD HOSTSEQUENCE INTEGER;  
UPDATE CLOSEDCASH SET HOSTSEQUENCE = 0;
ALTER TABLE CLOSEDCASH MODIFY HOSTSEQUENCE INTEGER NOT NULL;
CREATE INDEX CLOSEDCASH_SEQINX ON CLOSEDCASH(HOST, HOSTSEQUENCE);

ALTER TABLE RECEIPTS ADD ATTRIBUTES BLOB;

ALTER TABLE TICKETLINES DROP COLUMN NAME;
ALTER TABLE TICKETLINES DROP COLUMN ISCOM;

CREATE TABLE TAXLINES (
    ID VARCHAR2(255) NOT NULL,
    RECEIPT VARCHAR2(255) NOT NULL,
    TAXID VARCHAR2(255) NOT NULL, 
    BASE DOUBLE PRECISION NOT NULL, 
    AMOUNT DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (ID),
    CONSTRAINT TAXLINES_TAX FOREIGN KEY (TAXID) REFERENCES TAXES(ID)
);

UPDATE PEOPLE SET CARD = NULL WHERE CARD = '';

-- v2.20 - v2.30beta

INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('30', 'Printer.PartialCash', 0, $FILE{/com/openbravo/pos/templates/Printer.PartialCash.xml});

CREATE TABLE TEMP_PRODUCTS_COM (
    ID VARCHAR2(255) NOT NULL,
    PRODUCT VARCHAR2(255) NOT NULL,
    PRODUCT2 VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID)
);

INSERT INTO TEMP_PRODUCTS_COM(ID, PRODUCT, PRODUCT2) SELECT CONCAT(PRODUCT, PRODUCT2), PRODUCT, PRODUCT2 FROM PRODUCTS_COM;

ALTER TABLE PRODUCTS_COM DROP CONSTRAINT PRODUCTS_COM_FK_1;
ALTER TABLE PRODUCTS_COM DROP CONSTRAINT PRODUCTS_COM_FK_2;
DROP TABLE PRODUCTS_COM;

CREATE TABLE PRODUCTS_COM (
    ID VARCHAR2(255) NOT NULL,
    PRODUCT VARCHAR2(255) NOT NULL,
    PRODUCT2 VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID),
    CONSTRAINT PRODUCTS_COM_FK_1 FOREIGN KEY (PRODUCT) REFERENCES PRODUCTS(ID),
    CONSTRAINT PRODUCTS_COM_FK_2 FOREIGN KEY (PRODUCT2) REFERENCES PRODUCTS(ID)
);
CREATE UNIQUE INDEX PCOM_INX_PROD ON PRODUCTS_COM(PRODUCT, PRODUCT2);

INSERT INTO PRODUCTS_COM(ID, PRODUCT, PRODUCT2) SELECT ID, PRODUCT, PRODUCT2 FROM TEMP_PRODUCTS_COM;

DROP TABLE TEMP_PRODUCTS_COM;

ALTER TABLE TICKETS ADD TICKETTYPE INTEGER DEFAULT 0 NOT NULL;
DROP INDEX TICKETS_TICKETID;
CREATE INDEX TICKETS_TICKETID ON TICKETS(TICKETTYPE, TICKETID);
UPDATE TICKETS SET TICKETTYPE = 1 WHERE ID IN (SELECT RECEIPT FROM PAYMENTS WHERE TOTAL<0);

CREATE SEQUENCE TICKETSNUM_REFUND START WITH 1;
CREATE SEQUENCE TICKETSNUM_PAYMENT START WITH 1;

ALTER TABLE PAYMENTS ADD TRANSID VARCHAR2(255);
ALTER TABLE PAYMENTS ADD RETURNMSG BLOB;

CREATE TABLE ATTRIBUTE (
    ID VARCHAR2(255) NOT NULL,
    NAME VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID)
);

CREATE TABLE ATTRIBUTEVALUE (
    ID VARCHAR2(255) NOT NULL,
    ATTRIBUTE_ID VARCHAR2(255) NOT NULL,
    VALUE VARCHAR2(255),
    PRIMARY KEY (ID),
    CONSTRAINT ATTVAL_ATT FOREIGN KEY (ATTRIBUTE_ID) REFERENCES ATTRIBUTE(ID)
);

CREATE TABLE ATTRIBUTESET (
    ID VARCHAR2(255) NOT NULL,
    NAME VARCHAR2(255) NOT NULL,
    PRIMARY KEY (ID)
);

CREATE TABLE ATTRIBUTEUSE (
    ID VARCHAR2(255) NOT NULL,
    ATTRIBUTESET_ID VARCHAR2(255) NOT NULL,
    ATTRIBUTE_ID VARCHAR2(255) NOT NULL,
    LINENO INTEGER,
    PRIMARY KEY (ID),
    CONSTRAINT ATTUSE_SET FOREIGN KEY (ATTRIBUTESET_ID) REFERENCES ATTRIBUTESET(ID),
    CONSTRAINT ATTUSE_ATT FOREIGN KEY (ATTRIBUTE_ID) REFERENCES ATTRIBUTE(ID)
);
CREATE UNIQUE INDEX ATTUSE_LINE ON ATTRIBUTEUSE(ATTRIBUTESET_ID, LINENO);

CREATE TABLE ATTRIBUTESETINSTANCE (
    ID VARCHAR2(255) NOT NULL,
    ATTRIBUTESET_ID VARCHAR2(255) NOT NULL,
    DESCRIPTION VARCHAR2(255),
    PRIMARY KEY (ID),
    CONSTRAINT ATTSETINST_SET FOREIGN KEY (ATTRIBUTESET_ID) REFERENCES ATTRIBUTESET(ID)
);

CREATE TABLE ATTRIBUTEINSTANCE (
    ID VARCHAR2(255) NOT NULL,
    ATTRIBUTESETINSTANCE_ID VARCHAR2(255) NOT NULL,
    ATTRIBUTE_ID VARCHAR2(255) NOT NULL,
    VALUE VARCHAR2(255),
    PRIMARY KEY (ID),
    CONSTRAINT ATTINST_SET FOREIGN KEY (ATTRIBUTESETINSTANCE_ID) REFERENCES ATTRIBUTESETINSTANCE(ID),
    CONSTRAINT ATTINST_ATT FOREIGN KEY (ATTRIBUTE_ID) REFERENCES ATTRIBUTE(ID)
);

ALTER TABLE PRODUCTS ADD ATTRIBUTESET_ID VARCHAR2(255);
ALTER TABLE PRODUCTS ADD CONSTRAINT PRODUCTS_ATTRSET_FK FOREIGN KEY (ATTRIBUTESET_ID) REFERENCES ATTRIBUTESET(ID);

ALTER TABLE STOCKDIARY ADD ATTRIBUTESETINSTANCE_ID VARCHAR2(255);
ALTER TABLE STOCKDIARY ADD CONSTRAINT STOCKDIARY_ATTSETINST FOREIGN KEY (ATTRIBUTESETINSTANCE_ID) REFERENCES ATTRIBUTESETINSTANCE(ID);

CREATE TABLE STOCKLEVEL (
    ID VARCHAR2(255) NOT NULL,
    LOCATION VARCHAR2(255) NOT NULL,
    PRODUCT VARCHAR2(255) NOT NULL,
    STOCKSECURITY DOUBLE PRECISION,
    STOCKMAXIMUM DOUBLE PRECISION,
    PRIMARY KEY (ID),
    CONSTRAINT STOCKLEVEL_PRODUCT FOREIGN KEY (PRODUCT) REFERENCES PRODUCTS(ID),
    CONSTRAINT STOCKLEVEL_LOCATION FOREIGN KEY (LOCATION) REFERENCES LOCATIONS(ID)
);

INSERT INTO STOCKLEVEL(ID, LOCATION, PRODUCT, STOCKSECURITY, STOCKMAXIMUM) SELECT CONCAT(LOCATION, PRODUCT), LOCATION, PRODUCT, STOCKSECURITY, STOCKMAXIMUM FROM STOCKCURRENT;

CREATE TABLE TEMP_STOCKCURRENT (
    LOCATION VARCHAR2(255) NOT NULL,
    PRODUCT VARCHAR2(255) NOT NULL,
    ATTRIBUTESETINSTANCE_ID VARCHAR2(255),
    UNITS DOUBLE PRECISION NOT NULL
);

INSERT INTO TEMP_STOCKCURRENT(LOCATION, PRODUCT, UNITS) SELECT LOCATION, PRODUCT, UNITS FROM STOCKCURRENT;

ALTER TABLE STOCKCURRENT DROP CONSTRAINT STOCKCURRENT_FK_1;
ALTER TABLE STOCKCURRENT DROP CONSTRAINT STOCKCURRENT_FK_2;
DROP TABLE STOCKCURRENT;

CREATE TABLE STOCKCURRENT (
    LOCATION VARCHAR2(255) NOT NULL,
    PRODUCT VARCHAR2(255) NOT NULL,
    ATTRIBUTESETINSTANCE_ID VARCHAR2(255),
    UNITS DOUBLE PRECISION NOT NULL,
    CONSTRAINT STOCKCURRENT_FK_1 FOREIGN KEY (PRODUCT) REFERENCES PRODUCTS(ID),
    CONSTRAINT STOCKCURRENT_ATTSETINST FOREIGN KEY (ATTRIBUTESETINSTANCE_ID) REFERENCES ATTRIBUTESETINSTANCE(ID),
    CONSTRAINT STOCKCURRENT_FK_2 FOREIGN KEY (LOCATION) REFERENCES LOCATIONS(ID)
);
CREATE UNIQUE INDEX STOCKCURRENT_INX ON STOCKCURRENT(LOCATION, PRODUCT, ATTRIBUTESETINSTANCE_ID);

INSERT INTO STOCKCURRENT(LOCATION, PRODUCT, UNITS) SELECT LOCATION, PRODUCT, UNITS FROM TEMP_STOCKCURRENT;

DROP TABLE TEMP_STOCKCURRENT;

ALTER TABLE TICKETLINES ADD ATTRIBUTESETINSTANCE_ID VARCHAR2(255);
ALTER TABLE TICKETLINES ADD CONSTRAINT TICKETLINES_ATTSETINST FOREIGN KEY (ATTRIBUTESETINSTANCE_ID) REFERENCES ATTRIBUTESETINSTANCE(ID);

-- v2.30beta - v2.30

ALTER TABLE ATTRIBUTEVALUE DROP CONSTRAINT ATTVAL_ATT;
ALTER TABLE ATTRIBUTEVALUE ADD CONSTRAINT ATTVAL_ATT FOREIGN KEY (ATTRIBUTE_ID) REFERENCES ATTRIBUTE(ID) ON DELETE CASCADE;

ALTER TABLE ATTRIBUTEUSE DROP CONSTRAINT ATTUSE_SET;
ALTER TABLE ATTRIBUTEUSE ADD CONSTRAINT ATTUSE_SET FOREIGN KEY (ATTRIBUTESET_ID) REFERENCES ATTRIBUTESET(ID) ON DELETE CASCADE;

ALTER TABLE ATTRIBUTESETINSTANCE DROP CONSTRAINT ATTSETINST_SET;
ALTER TABLE ATTRIBUTESETINSTANCE ADD CONSTRAINT ATTSETINST_SET FOREIGN KEY (ATTRIBUTESET_ID) REFERENCES ATTRIBUTESET(ID) ON DELETE CASCADE;

ALTER TABLE ATTRIBUTEINSTANCE DROP CONSTRAINT ATTINST_SET;
ALTER TABLE ATTRIBUTEINSTANCE ADD CONSTRAINT ATTINST_SET FOREIGN KEY (ATTRIBUTESETINSTANCE_ID) REFERENCES ATTRIBUTESETINSTANCE(ID) ON DELETE CASCADE;

ALTER TABLE PRODUCTS MODIFY ISCOM NUMERIC(1) DEFAULT 0;
ALTER TABLE PRODUCTS MODIFY ISSCALE NUMERIC(1) DEFAULT 0;
ALTER TABLE TAXES MODIFY RATECASCADE NUMERIC(1) DEFAULT 0;
ALTER TABLE CUSTOMERS MODIFY VISIBLE NUMERIC(1) DEFAULT 1;

-- v2.30 - v2.30.1

ALTER TABLE TAXES ADD VALIDFROM TIMESTAMP DEFAULT TO_DATE('2001-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') NOT NULL;

-- final script

DELETE FROM SHAREDTICKETS;

UPDATE APPLICATIONS SET NAME = $APP_NAME{}, VERSION = $APP_VERSION{} WHERE ID = $APP_ID{};
