-- NAICS 2022 sample data (US Census Bureau, public domain)
-- Sectors (level 2), selected subsectors (level 3), and industries (level 6)

-- Agriculture, Forestry, Fishing and Hunting
INSERT INTO naics_code (code, title, level) VALUES ('11', 'Agriculture, Forestry, Fishing and Hunting', 2);
INSERT INTO naics_code (code, title, level) VALUES ('111', 'Crop Production', 3);
INSERT INTO naics_code (code, title, level) VALUES ('112', 'Animal Production and Aquaculture', 3);

-- Mining, Quarrying, and Oil and Gas Extraction
INSERT INTO naics_code (code, title, level) VALUES ('21', 'Mining, Quarrying, and Oil and Gas Extraction', 2);

-- Utilities
INSERT INTO naics_code (code, title, level) VALUES ('22', 'Utilities', 2);

-- Construction
INSERT INTO naics_code (code, title, level) VALUES ('23', 'Construction', 2);

-- Manufacturing
INSERT INTO naics_code (code, title, level) VALUES ('31', 'Manufacturing', 2);
INSERT INTO naics_code (code, title, level) VALUES ('32', 'Manufacturing', 2);
INSERT INTO naics_code (code, title, level) VALUES ('33', 'Manufacturing', 2);
INSERT INTO naics_code (code, title, level) VALUES ('311', 'Food Manufacturing', 3);
INSERT INTO naics_code (code, title, level) VALUES ('334', 'Computer and Electronic Product Manufacturing', 3);

-- Wholesale Trade
INSERT INTO naics_code (code, title, level) VALUES ('42', 'Wholesale Trade', 2);

-- Retail Trade
INSERT INTO naics_code (code, title, level) VALUES ('44', 'Retail Trade', 2);
INSERT INTO naics_code (code, title, level) VALUES ('45', 'Retail Trade', 2);

-- Transportation and Warehousing
INSERT INTO naics_code (code, title, level) VALUES ('48', 'Transportation and Warehousing', 2);
INSERT INTO naics_code (code, title, level) VALUES ('49', 'Transportation and Warehousing', 2);

-- Information
INSERT INTO naics_code (code, title, level) VALUES ('51', 'Information', 2);
INSERT INTO naics_code (code, title, level) VALUES ('511', 'Publishing Industries', 3);
INSERT INTO naics_code (code, title, level) VALUES ('512', 'Motion Picture and Sound Recording Industries', 3);
INSERT INTO naics_code (code, title, level) VALUES ('517', 'Telecommunications', 3);
INSERT INTO naics_code (code, title, level) VALUES ('518', 'Computing Infrastructure Providers, Data Processing, Web Hosting, and Related Services', 3);
INSERT INTO naics_code (code, title, level) VALUES ('519', 'Web Search Portals, Libraries, Archives, and Other Information Services', 3);
INSERT INTO naics_code (code, title, level) VALUES ('511210', 'Software Publishers', 6);
INSERT INTO naics_code (code, title, level) VALUES ('518210', 'Computing Infrastructure Providers, Data Processing, Web Hosting, and Related Services', 6);
INSERT INTO naics_code (code, title, level) VALUES ('519210', 'Libraries and Archives', 6);

-- Finance and Insurance
INSERT INTO naics_code (code, title, level) VALUES ('52', 'Finance and Insurance', 2);
INSERT INTO naics_code (code, title, level) VALUES ('522', 'Credit Intermediation and Related Activities', 3);
INSERT INTO naics_code (code, title, level) VALUES ('524', 'Insurance Carriers and Related Activities', 3);

-- Real Estate and Rental and Leasing
INSERT INTO naics_code (code, title, level) VALUES ('53', 'Real Estate and Rental and Leasing', 2);

-- Professional, Scientific, and Technical Services
INSERT INTO naics_code (code, title, level) VALUES ('54', 'Professional, Scientific, and Technical Services', 2);
INSERT INTO naics_code (code, title, level) VALUES ('541', 'Professional, Scientific, and Technical Services', 3);
INSERT INTO naics_code (code, title, level) VALUES ('541511', 'Custom Computer Programming Services', 6);
INSERT INTO naics_code (code, title, level) VALUES ('541512', 'Computer Systems Design Services', 6);
INSERT INTO naics_code (code, title, level) VALUES ('541519', 'Other Computer Related Services', 6);

-- Management of Companies and Enterprises
INSERT INTO naics_code (code, title, level) VALUES ('55', 'Management of Companies and Enterprises', 2);

-- Administrative and Support and Waste Management
INSERT INTO naics_code (code, title, level) VALUES ('56', 'Administrative and Support and Waste Management and Remediation Services', 2);

-- Educational Services
INSERT INTO naics_code (code, title, level) VALUES ('61', 'Educational Services', 2);

-- Health Care and Social Assistance
INSERT INTO naics_code (code, title, level) VALUES ('62', 'Health Care and Social Assistance', 2);
INSERT INTO naics_code (code, title, level) VALUES ('621', 'Ambulatory Health Care Services', 3);
INSERT INTO naics_code (code, title, level) VALUES ('622', 'Hospitals', 3);

-- Arts, Entertainment, and Recreation
INSERT INTO naics_code (code, title, level) VALUES ('71', 'Arts, Entertainment, and Recreation', 2);

-- Accommodation and Food Services
INSERT INTO naics_code (code, title, level) VALUES ('72', 'Accommodation and Food Services', 2);

-- Other Services (except Public Administration)
INSERT INTO naics_code (code, title, level) VALUES ('81', 'Other Services (except Public Administration)', 2);

-- Public Administration
INSERT INTO naics_code (code, title, level) VALUES ('92', 'Public Administration', 2);
INSERT INTO naics_code (code, title, level) VALUES ('928', 'National Security and International Affairs', 3);
INSERT INTO naics_code (code, title, level) VALUES ('928110', 'National Security', 6);
