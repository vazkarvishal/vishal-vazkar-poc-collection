# AWS OpenSearch Domain Reporter

## Description
This script automates the process of collecting and recording AWS OpenSearch domain details into an Excel file. It interacts with AWS services using the Boto3 library and manages Excel sheets using Openpyxl. It retrieves information about all OpenSearch domains in the current AWS account, including the number of nodes and instance types, and either updates this data in an existing Excel sheet or appends it to a new one.


## Benefits/Usage
- Allows collecting all OpenSearch domains in a given AWS account and their instance types.
- Can be used for bulk improvements like changing OS domains in Bulk to serverless or Graviton
- General tracking

## Features
- Retrieves current AWS account ID
- Lists all OpenSearch domains in the account
- Extracts detailed information such as number of nodes and instance type for each domain
- Updates or appends this information in an Excel sheet
- Handles creation of new Excel file if none exists

## Requirements
- Python 3.x
- Boto3
- Openpyxl

## Installation
- `pip3 install -r requirements.txt`

## Running
- Make sure you have logged into the correct account using AWS CLI, using the correct profile
- Run `pip3 main.py`
- Results should be in the EXCEL generated

