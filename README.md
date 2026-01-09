# Eniac & Magist Market Expansion Case Study

**SQL (MySQL) & Tableau | WBS Data Science Bootcamp Project**

-----------------------------------------------------------

## Project Overview 

This project is a business-driven data analysis case study conducted as part of the WBS Data Science bootcamp. The goal is to help Eniac, a European e-commerce company that sells Apple-compatible accessories, decide whether partnering with Magist, a Brazilian logistics and order management platform, is a good option for expanding into the Brazilian market.

Eniac wants to grow quickly in Brazil but lacks local logistics, providers, and market knowledge. Magist could help solve this problem and Eniac is considering signing a 3-year partnership contract with Magist, but there are concerns about whether Magist is the right fit for Eniac’s products and delivery standards. Specifically, the goals are to understand whether:
1.  Magist is a good partner for the high-end tech products that Eniac specialises in, and
2.  Magist's delivery times are fast enough to ensure customer satisfaction

Using a snapshot of Magist’s orders and delivery database, this project evaluates whether Magist is a viable strategic partner for Eniac’s expansion into Brazil.

The final outcome is a short presentation (3–5 minutes) aimed at Eniac’s leadership team, clearly explaining insights and recommendations.

------------------------------------------------------------

## Tools used 

- **SQL (MySQL)**
  - Used for exploring and analysing data through mutliple joined data tables to inform Eniac's strategic decision making by extracting and calculating key statistics regarding Magist's products, customers, sales, revenues, and delivery times. 

- **Tableau**
  - Created data visualisations to illustrate the story behind the numbers and communicate the results of the analysis clearly, using maps and bar charts.
 
- **Google slides**
  - For collaborative work to present the findings and recommendations of the data team regarding the partership with Magist.
 
------------------------------------------------------------

## Project files

- **Presentation file**: `Magist Data Analysis.pdf`
  - A PDF of the final presentation to the CEO, outlining the key statistics and recommendations of the data team.
 
- **Tableau file**: `deliveries_reviews.twb`
  - Includes visualisations (bar charts and maps) that illustrate Magist's expected and actual delivery times across states for their online orders.
 
- **MySQL files**: `data_exploration.sql` and `business_questions.sql`
  - These files contain the SQL queries used to explore Magist's dataset and to answer specific business queries regarding Magist's portfolio and performance with respect to sales, revenue, delivery times, and customer satisfaction.
 
-----------------------------------------------------------

## How to use the files

- **Take a look at the presentation**:
  - The presentation file contains the key takeaways and recommendations from the data team regarding the suitability of Magist for a partnership with Eniac in Brazil.
 
- **Explore the data visualisations**:
  - The Tableau file includes several figures, including maps and bar charts, illustrating key findings about Magist's expected and actual delivery times across Brazilian states.
 
- **Dive into the data**:
  - The two SQL files contain the SQL queries used to interrogate the Magist dataset, providing key insights into Magist's performance and suitability as a local partner in Brazil.
 
----------------------------------------------------------

## Summary of key insights

- **Brazil is an attractive but unfamiliar market**
  - Brazil is the largest electronics consumer market in Latin America, with strong projected growth over the next decade. Expanding there would allow Eniac to diversify beyond relatively mature European markets. However, Eniac lacks local infrastructure, which makes a partner like Magist appealing as a short-term solution .
 
- **Magist does sell tech products — but at a very different price point**
  - Magist’s marketplace includes tech-related categories (electronics, computers, accessories, phones, tablets), but these products are generally much cheaper (average €105) than Eniac’s catalog (average €540).
  - Tech products account for about 10% of Magist’s orders and 13.7% of its revenue, suggesting that tech is present but not central to Magist’s business. In absolute terms, Magist’s annual tech revenue (~€1M) is far smaller than Eniac’s (~€14M), which raises questions about market fit for Eniac's high-end tech products 

- **Delivery performance is mostly reliable by Brazilian standards**
  - Magist delivers over 91% of orders on time relative to its own estimated delivery dates, including tech orders. This indicates good reliability. However:
    - Estimated delivery times are long and vary significantly by region
      - São Paulo: ~19 days estimated / ~8 days actual
      - Roraima: up to ~46 days estimated / ~29 days actual
  - That said, Magist’s actual delivery times (≈12 days on average) are better than the Brazilian national average for e-commerce deliveries (~16 days). In a Brazilian context, Magist performs reasonably well — but expectations would need to be managed for customers used to faster European shipping 

- **Customer satisfaction is generally strong**
  - Customer reviews suggest that Magist users are mostly satisfied:
    - Average review score: 4.1 / 5
  - Tech orders score slightly lower (~3.95) but still positive
  - This indicates that long delivery times are likely accepted as normal within the Brazilian market, and Magist meets local customer expectations 

------------------------------------------------------------

# Overall Takeaway

- Magist is operationally reliable and performs well relative to Brazilian e-commerce norms.
- Delivery speed is acceptable for Brazil, but slower and less predictable than what Eniac customers in Europe may expect.
- Customer satisfaction with Magist is generally high.
- Product and pricing mismatch is the biggest concern: Magist is geared toward lower-priced tech products, while Eniac operates in a premium segment.
- As a result, Magist makes sense as a short-term, low-risk entry strategy, but not necessarily as a long-term partner for Eniac.
