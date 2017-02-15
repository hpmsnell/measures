# measures
This repo houses the Able Health measures library, which includes measure specifications, configuration files, test data, and value sets for all measures starting January 1, 2017.

Further documentation is available in the [Measures Wiki](https://github.com/AbleHealth/measures/wiki).

## Measure Specifications
Measure specifications specify the logic for each measure and are written in Clinical Quality Language (CQL) version 1.0, using the Quality Data Model (QDM) version 5.0.

Each measure specification specifies the logic for placing a patient or episode of care in one of the following "populations":

* Denominator
* Denominator exclusion reason
* Numerator performance met reason
* Denominator exception reason
* Numerator performance not met reason

Value sets come from a number of sources, such as VSAC and HEDIS. Each value set is identified by a source and name, e.g. `VSAC; Palliative Care` and paired with a QDM element, such as `Procedure, Performed`.

[View the template for measure specs here](https://github.com/AbleHealth/measures/blob/master/templates/spec_template.cql)

For more information:

* [Clinical Quality Language](https://ecqi.healthit.gov/cql)
* [Quality Data Model](https://ecqi.healthit.gov/qdm)
* [QDM-Able Domain Mapping](https://docs.google.com/a/ablehealth.com/spreadsheets/d/1rqgov-26ChvKZEIPy1i1L1TxlQ9T8vduY0-EZccpx_s/edit?usp=sharing)

## Configuration Files
Configuration files specify the metadata for each measure and are written in YAML.

Each file contains the following metadata for each measure:

* Able measure ID
* Display name
* External set
* External ID
* External version
* Gap resolution action
* Exclusion, numerator performance met, and numerator performance not met reasons:
    * Metadata identifier link
    * Display title (message copy displayed to the user)
    * Validation record groupings (each grouping specifies one or more records displayed in the validation record table for the reason):
        * Count (number of most recent records to display)
        * Value sets (model and value set name)

Validation records are specified using Able domain model categories, as specified [in this mapping (see "Able to YAML" tab)](https://docs.google.com/a/ablehealth.com/spreadsheets/d/1rqgov-26ChvKZEIPy1i1L1TxlQ9T8vduY0-EZccpx_s/edit?usp=sharing).

[View the template for config files here](https://github.com/AbleHealth/measures/blob/master/templates/measure_metadata.yml)  
[Use this tool to validate config files](https://acceptance.ablehealth.com/able_admin/measure_config_format_validations/new)

## Test Data
Test data files specify the clinical data for all test patients, as well as an organization-level test key, and are written in YAML. Test data files are used for both patient-based and episode-of-care-based measures. Test data should be evaluated using the 2016 calendar year (2016-01-01 to 2016-12-31) as the measurement period.

Each file contains the following data:

* Able measure ID
* Organization-level and provider-level test keys
    * Expected population results for each patient or episode of care (denominator, denominator exclusion, denominator exception, numerator)
* Provider information
* Clinical data for each patient
    * Attributes (first name, last name, sex, date of birth)
    * Clinical models, codes, and associated metadata
    
Validation records are specified using Able domain model categories, as specified [in this mapping (see "Able to YAML" tab)](https://docs.google.com/a/ablehealth.com/spreadsheets/d/1rqgov-26ChvKZEIPy1i1L1TxlQ9T8vduY0-EZccpx_s/edit?usp=sharing).

[View the template for test data files here](https://github.com/AbleHealth/measures/blob/master/templates/test_data_with_key.yml)  
[Use this tool to validate test data files](https://acceptance.ablehealth.com/able_admin/measure_test_set_format_validations/new)

## Value Sets
Value sets can be found in the `value_sets` directory in CSV format according to source, e.g. `VSAC` or `Able`. CSVs can be downloaded and imported into the application.
