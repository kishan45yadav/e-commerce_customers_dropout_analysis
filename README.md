🛒 E-Commerce Customer Drop-Out Analysis

Analyzing where and why customers drop out before completing a purchase on an e-commerce marketplace, using SQL and Python on a multi-table transactional dataset.

📌 Project Objective

To trace the customer purchase journey end-to-end — from order placement to delivery — and identify the exact stage(s), patterns, and contributing factors behind orders that fail to convert into completed, delivered purchases.

🗂️ Dataset

A multi-table e-commerce dataset (Olist-style) loaded into PostgreSQL, covering:

Table	Rows	Description
customers	99,441	Customer identity & location
orders	99,441	Order lifecycle timestamps & status
order_items	112,650	Line-item level product, seller, price
order_reviews	99,224	Post-purchase review scores
products	32,951	Product attributes
product_category	71	Category name translation
sellers	3,095	Seller identity & location
geolocation	738,327	Zip code coordinate mapping
🛠️ Tools & Tech Stack
Database: PostgreSQL (pgAdmin)
Query Language: SQL — CTEs, conditional aggregation, window functions
Analysis & Visualization: Python — pandas, SQLAlchemy, matplotlib, seaborn, plotly
Environment: Jupyter Notebook
🔍 Methodology
Loaded and validated all 8 datasets into PostgreSQL.
Defined the purchase funnel using order timestamps: Purchased → Approved → Shipped → Delivered.
Classified "drop-out" orders as those marked canceled or unavailable.
Measured drop-out as both raw counts and failure rate (%) to avoid volume bias.
Cross-examined drop-out by funnel stage, product category, and seller.
📊 Key Findings
1. Order Status Distribution

97.02% of all orders were successfully delivered. The remaining ~3% is split across cancellations, unavailable stock, and orders stuck mid-process.
![image alt](https://github.com/kishan45yadav/e-commerce_customers_dropout_analysis/blob/main/order_status_distribution.png?raw=true)


2. Funnel Analysis — Where Orders Are Lost
Stage	Orders Remaining	Drop from Previous Stage
Purchased	99,441	—
Approved	99,281	-160 (0.16%)
Shipped	97,658	-1,623 (1.63%)
Delivered	96,476	-1,182 (1.21%)

➡️ The Approved → Shipped transition is the single largest leak in the funnel.

3. Cancellation Timing

Of 625 total canceled orders:

65.4% were canceled after payment approval, before shipping — pointing to a seller-side fulfillment failure, not customer intent.
22.6% were canceled before approval (likely customer/payment-driven).
11.0% were canceled after shipping, before delivery (likely logistics-driven).
4. Category-Wise Failure Rate

Failure rates are fairly uniform across categories (mostly 1–3%), with no single category standing out as a systemic outlier. → Drop-out is not primarily a category-specific problem.

5. Seller-Wise Failure Rate

This is the standout finding: failure rates vary dramatically by seller. The top sellers show failure rates of 17–20% — up to 20x the platform baseline (~1%). → Drop-out is a meaningful, actionable, seller-specific performance problem.

💡 Recommendations
Implement automated seller performance monitoring with a failure-rate flag (e.g., >5% over a rolling 20+ order window).
Introduce stricter inventory/stock verification before a listing can accept orders, to reduce "unavailable" cancellations.
Audit and support (or deprioritize) sellers with consistently high post-approval cancellation rates.
Investigate courier/logistics performance for the Shipped → Delivered leak as a secondary workstream.
Extend the analysis with review-score and repeat-purchase data to quantify the downstream impact on customer retention.
📁 Repository Structure
├── notebooks/     → Jupyter notebook with full analysis
├── sql/           → SQL queries used for each stage of analysis
├── charts/        → Exported visualizations (PNG)
└── report/        → Full written report (DOCX)
👤 Author

Kishan Yadav Portfolio: kishan45yadav.github.io GitHub: @kishan45yadav
