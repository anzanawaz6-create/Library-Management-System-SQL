-- ============================================================
--  Library Management System - DDL
-- ============================================================

CREATE DATABASE LibraryDB;
USE LibraryDB;

-- Table 1: Category
CREATE TABLE Category (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100),
    description   VARCHAR(255)
);

-- Table 2: Author
CREATE TABLE Author (
    author_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    nationality VARCHAR(50),
    bio         TEXT
);

-- Table 3: Member
CREATE TABLE Member (
    member_id         INT PRIMARY KEY AUTO_INCREMENT,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    email             VARCHAR(100),
    phone             VARCHAR(20),
    address           VARCHAR(255),
    membership_date   DATE,
    membership_status VARCHAR(20)
);

-- Table 4: Book
CREATE TABLE Book (
    book_id          INT PRIMARY KEY AUTO_INCREMENT,
    isbn             VARCHAR(20),
    title            VARCHAR(200),
    author_id        INT,
    category_id      INT,
    publisher        VARCHAR(100),
    published_year   YEAR,
    total_copies     INT,
    available_copies INT,
    FOREIGN KEY (author_id)   REFERENCES Author(author_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Table 5: Borrowing
CREATE TABLE Borrowing (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id    INT,
    book_id      INT,
    borrow_date  DATE,
    due_date     DATE,
    status       VARCHAR(20),
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (book_id)   REFERENCES Book(book_id)
);

-- Table 6: Returns
CREATE TABLE Returns (
    return_id      INT PRIMARY KEY AUTO_INCREMENT,
    borrowing_id   INT,
    return_date    DATE,
    condition_note VARCHAR(100),
    processed_by   VARCHAR(50),
    FOREIGN KEY (borrowing_id) REFERENCES Borrowing(borrowing_id)
);

-- Table 7: Fine
CREATE TABLE Fine (
    fine_id      INT PRIMARY KEY AUTO_INCREMENT,
    borrowing_id INT,
    fine_amount  DECIMAL(8,2),
    paid_status  VARCHAR(10),
    fine_date    DATE,
    FOREIGN KEY (borrowing_id) REFERENCES Borrowing(borrowing_id)
);


-- ============================================================
--  Library Management System - DML
-- ============================================================

-- Insert Category
INSERT INTO Category (category_name, description) VALUES
('Science Fiction',  'Futuristic and speculative fiction'),
('Computer Science', 'Programming and technology books'),
('History',          'Historical events and biographies'),
('Mathematics',      'Pure and applied mathematics'),
('Literature',       'Classic and modern literary works');

-- Insert Author
INSERT INTO Author (first_name, last_name, nationality, bio) VALUES
('Isaac',  'Asimov',   'American', 'Prolific sci-fi and popular science author'),
('Donald', 'Knuth',    'American', 'Author of The Art of Computer Programming'),
('Yuval',  'Harari',   'Israeli',  'Author of Sapiens and Homo Deus'),
('George', 'Orwell',   'British',  'Author of 1984 and Animal Farm'),
('Agatha', 'Christie', 'British',  'Queen of crime fiction mystery novels');

-- Insert Member
INSERT INTO Member (first_name, last_name, email, phone, address, membership_date, membership_status) VALUES
('Ali',    'Hassan',   'ali.hassan@lib.pk',   '0311-1010101', 'House 5, Lahore',   '2024-01-10', 'Active'),
('Fatima', 'Noor',     'fatima.noor@lib.pk',  '0312-2020202', 'House 8, Lahore',   '2024-02-15', 'Active'),
('Hassan', 'Siddiqui', 'hassan.sid@lib.pk',   '0313-3030303', 'House 12, Karachi', '2024-03-20', 'Active'),
('Zainab', 'Mirza',    'zainab.mirza@lib.pk', '0314-4040404', 'House 3, Lahore',   '2024-04-05', 'Active'),
('Omar',   'Sheikh',   'omar.sheikh@lib.pk',  '0315-5050505', 'House 7, Lahore',   '2024-05-01', 'Suspended');

-- Insert Book
INSERT INTO Book (isbn, title, author_id, category_id, publisher, published_year, total_copies, available_copies) VALUES
('978-0-553-29335-7', 'Foundation',                     1, 1, 'Gnome Press',      1951, 5, 4),
('978-0-201-89683-1', 'The Art of Computer Programming', 2, 2, 'Addison-Wesley',   1968, 3, 2),
('978-0-062-31609-7', 'Sapiens',                        3, 3, 'Harper Collins',   2011, 4, 3),
('978-0-451-52493-5', '1984',                           4, 5, 'Secker & Warburg', 1949, 6, 6),
('978-0-007-11934-9', 'And Then There Were None',       5, 5, 'Collins Crime',    1939, 4, 4);

-- Insert Borrowing
INSERT INTO Borrowing (member_id, book_id, borrow_date, due_date, status) VALUES
(1, 1, '2026-05-01', '2026-05-15', 'Returned'),
(1, 3, '2026-05-10', '2026-05-24', 'Borrowed'),
(2, 2, '2026-05-05', '2026-05-19', 'Returned'),
(2, 4, '2026-05-20', '2026-06-03', 'Borrowed'),
(3, 5, '2026-05-12', '2026-05-26', 'Returned'),
(4, 1, '2026-05-15', '2026-05-29', 'Overdue'),
(1, 5, '2026-06-01', '2026-06-15', 'Borrowed');

-- Insert Returns
INSERT INTO Returns (borrowing_id, return_date, condition_note, processed_by) VALUES
(1, '2026-05-14', 'Good', 'Staff-A'),
(3, '2026-05-20', 'Good', 'Staff-B'),
(5, '2026-05-25', 'Good', 'Staff-A');

-- Insert Fine
INSERT INTO Fine (borrowing_id, fine_amount, paid_status, fine_date) VALUES
(3, 100.00, 'Paid', '2026-05-21');

-- UPDATE: Change membership status
UPDATE Member
SET    membership_status = 'Expired'
WHERE  member_id = 5;

-- DELETE: Remove a fine record
DELETE FROM Fine
WHERE fine_id = 1;

Trigger Code
-- ============================================================
--  Trigger: Auto generate fine on late return
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_AutoFineOnReturn
AFTER INSERT ON Returns
FOR EACH ROW
BEGIN
    DECLARE v_due_date   DATE;
    DECLARE overdue_days INT;
    DECLARE fine_amt     DECIMAL(8,2);

    SELECT due_date INTO v_due_date
    FROM   Borrowing
    WHERE  borrowing_id = NEW.borrowing_id;

    SET overdue_days = DATEDIFF(NEW.return_date, v_due_date);

    IF overdue_days > 0 THEN
        IF overdue_days <= 5 THEN
            SET fine_amt = overdue_days * 10.00;
        ELSEIF overdue_days <= 10 THEN
            SET fine_amt = overdue_days * 20.00;
        ELSE
            SET fine_amt = overdue_days * 50.00;
        END IF;

        INSERT INTO Fine (borrowing_id, fine_amount, paid_status, fine_date)
        VALUES (NEW.borrowing_id, fine_amt, 'Unpaid', NEW.return_date);
    END IF;

    UPDATE Book
    SET    available_copies = available_copies + 1
    WHERE  book_id = (
        SELECT book_id FROM Borrowing WHERE borrowing_id = NEW.borrowing_id
    );

    UPDATE Borrowing
    SET    status = 'Returned'
    WHERE  borrowing_id = NEW.borrowing_id;

END$$

DELIMITER ;
SELECT  book_id, isbn, title, publisher,
        available_copies, total_copies
FROM    Book
WHERE   available_copies > 0
ORDER BY title;

SELECT  CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        b.title    AS book_title,
        br.borrow_date,
        br.due_date,
        r.return_date,
        br.status,
        f.fine_amount,
        f.paid_status
FROM    Member    m
JOIN    Borrowing br ON m.member_id     = br.member_id
JOIN    Book      b  ON br.book_id       = b.book_id
LEFT JOIN Returns r  ON br.borrowing_id  = r.borrowing_id
LEFT JOIN Fine    f  ON br.borrowing_id  = f.borrowing_id
ORDER BY br.borrow_date DESC;
SELECT  c.category_name,
        COUNT(b.book_id)        AS total_books,
        SUM(b.total_copies)     AS total_copies,
        SUM(b.available_copies) AS available_copies
FROM    Category c
JOIN    Book     b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
HAVING  COUNT(b.book_id) > 1
ORDER BY total_books DESC;
SELECT  CONCAT(first_name, ' ', last_name) AS member_name, email
FROM    Member
WHERE   member_id IN (
    SELECT DISTINCT br.member_id
    FROM   Borrowing br
    JOIN   Book      b  ON br.book_id    = b.book_id
    JOIN   Category  c  ON b.category_id = c.category_id
    WHERE  c.category_name = 'Science Fiction'
);
SELECT  CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        m.email, m.membership_status
FROM    Member m
WHERE   EXISTS (
    SELECT 1
    FROM   Borrowing br
    WHERE  br.member_id = m.member_id
    AND    br.status    IN ('Borrowed', 'Overdue')
    AND    NOT EXISTS (
        SELECT 1 FROM Returns r
        WHERE  r.borrowing_id = br.borrowing_id
    )
);

CREATE OR REPLACE VIEW vw_BorrowingSummary AS
SELECT  m.member_id,
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        b.isbn,
        b.title                     AS book_title,
        br.borrow_date,
        br.due_date,
        r.return_date,
        br.status,
        IFNULL(f.fine_amount, 0.00) AS fine_amount,
        IFNULL(f.paid_status, 'N/A') AS fine_status
FROM    Member    m
JOIN    Borrowing br ON m.member_id     = br.member_id
JOIN    Book      b  ON br.book_id       = b.book_id
LEFT JOIN Returns r  ON br.borrowing_id  = r.borrowing_id
LEFT JOIN Fine    f  ON br.borrowing_id  = f.borrowing_id;

-- Use the view:
SELECT * FROM vw_BorrowingSummary ORDER BY member_name;

SELECT  b.book_id, b.title, b.isbn,
        CONCAT(a.first_name, ' ', a.last_name) AS author_name
FROM    Book   b
JOIN    Author a ON b.author_id = a.author_id
WHERE   b.title      LIKE '%The%'
   OR   a.last_name  LIKE 'A%';
   INSERT INTO Returns (return_id, borrowing_id, return_date)
VALUES (10, 1, '2026-06-07');
INSERT INTO Returns (return_id, borrowing_id, return_date)
VALUES (11, 2, '2026-06-03');
   SELECT * FROM Fine;
   