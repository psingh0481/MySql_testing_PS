# PROG8850 Assignment 5
environment with mysql, python, node and docker

TLDR;

```bash
pip install -r requirements.txt
sudo service mysql start
```

To access database:

```bash
sudo mysql -u root
```

Download `archive.zip`, a dataset of ~100,000 ecommerce orders from [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download) using your google id. Make a mysql database using ansible to create the schema and import the data from the .csv files. Make some tests that time queries on amount and other scalar fields in te database.

Use the `MATCH () ... AGAINST` syntax to test some full text searches and time them as well.

Use EXPLAIN to investigate how your searches are being run.

Create indexes and re-run your tests and timings. Make some notes and commit them to this repository of who would be interested in running your searches and what their goals are. Note how your performance improvements would help them achieve their goals.

## Marking

|Item|Out Of|
|--|--:|
|up.yaml creating the database|1|
|up.yaml loading csv data|2|
|tests of scalar fields like amounts|2|
|tests of full text searches|2|
|up.yaml to create indices|2|
|explanation of searches, goals and outcomes of indexing|1|
|||
|total|10|
