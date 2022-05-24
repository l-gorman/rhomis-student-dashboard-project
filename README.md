# RHoMIS Dashboard Student Project

This repository was set up to support computer science
students hoping to build a dashboard that would intergate
into the RHoMIS 2.0 system. The dashboard should summarise
data from the publicly available RHoMIS data, which can be
found [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/TFXQJN)

# Materials

## Installation and Cloning

To get started you will need to:

- clone this repository
- install R
- install mongoDB (community edition)
- install node/npm
- fork the [authentication api](https://github.com/l-gorman/rhomis-authenticator)
- fork the [data api](https://github.com/l-gorman/rhomis-api)

You can learn about mongoDB, and how to interact with it [here](https://www.mongodb.com/docs/mongodb-shell/)

## Setup

I have created a script for you to load all of the RHoMIS data into a local
mongoDB database. Download the data [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/TFXQJN)
as a zip file. Extract the contents from the zip file and place them in the blank `data`
directory found in this repository. The folder should contain files like this
`data/.original_calorie_conversions`, `data/calorie_conversions`...

I have created an R virtual environment (renv) for you. To load the correct packages, run the setup.R
script. You can do this with the command:

`Rscript src/setup.R`

Once you have loaded the packages from renv, and downloaded the data from the datavers in the correct
format. You are then ready to load the data into the mongoDB database. you can do this by running the
`src/load_data.R` script.

# Information on the APIs

The APIs use Express JS. If you are in the API directory, you can start a local
version of the api using the command `npm run start-dev`. Make sure you have
mongoDB running, otherwise the APIs will not work. Documentation for each
of the APIs is available at their respective links (see above).

# Information on the Databases

There are two databases you will be working with. One for authentication (rhomis-auth-dev).
It is unlikely that you will need to change anything in the authentication
database. Then there is the rhomis-data-dev. this is likely the one you will
work more with.

The `rhomis-data-dev` database stores information on all of the projects. There are a few collections in this database.

The first collection is the projectData collection:

```
{

_id: ObjectId("626a9a3ceea8ef0f176c2469"),
    formID: 'test_form_id',
    projectID: 'test_project_id',
    __v: 0,
    units: [
      'country',
      'crop_name',
    ...
    ],
    unitsExtracted: true,
    dataSets: [
      'indicatorData',
      'processedData',
      'crop_harvest_kg_per_year',
      'crop_consumed_kg_per_year',
      'crop_sold_kg_per_year',
      'crop_income_per_year',
    ...

    ],
    pricesCalculated: true,
    finalIndicators: true

}
```

The fields `projectID` and `formID` are used to index projects and forms. The `units` field indicates any
units and conversion factors associated with a RHoMIS
project. The fields `unitsExtracted`, `pricesCalculated`, and
`finalIndicators` all indicate different processing stages. In
the case of the public data, all of these processing stages have already occured.

The collections `forms` and `projects` contain information
from the authentication API. This includes information on
individual surveys. The collection `units_and_conversions_log`
contains history of previous unit conversions which have been used and modified byn users.

Finally, we have two collections which actually contain the
data on each of the projects. First we have the "units_and_conversions" collection. This collection
corresponds to the `units` field of the `projectData`
collection. It contains all of the units for an individual
project. The second collection is `data`. This corresponds to
the `dataSets` field of the `projectData` collection.

The `data` and `projectData` collections are likely what
you will use to create a dashboard. The contents of the
`data` collection look like this:

```
[
        {
        _id: ObjectId("626a5d73eea8ef0f176bb6de"),
        dataType: 'milk_price_per_litre',
        formID: 'test_form_id',
        projectID: 'test_project_id',
        data: [
        {
            id_unique: 'uuid:403d9bcf-28d5-45bb-bfba-61d20ec7bcf1',
            id_hh: 'e0bc297205b08a6aa49d6c9b3cc8b8cc',
            id_rhomis_dataset: 'cd61facdcf970db01abdac65c5392aeb',
            id_form: 'test_form_id',
            id_proj: 'test_project_id',
            buffalo: null,
            bees: null
            ...
        },
        {
            id_unique: 'uuid:0b5207f3-db01-4668-bfed-dbe1a604e0ac',
            id_hh: '997f602e95e38cd40aed59aa4f7debad',
            id_rhomis_dataset: '52ebcf202d36fcb4cd18bf0ac6553c28',
            id_form: 'test_form_id',
            id_proj: 'test_project_id',
            buffalo: null,
            bees: null
            ...
        },
        ...
        ]
    },

    {
        _id: ObjectId("626a5d73eea8ef0f176bb6de"),
        dataType: 'milk_price_per_litre',
        formID: 'test_form_id',
        projectID: 'test_project_id',
        data: [
        {
            id_unique: 'uuid:403d9bcf-28d5-45bb-bfba-61d20ec7bcf1',
            id_hh: 'e0bc297205b08a6aa49d6c9b3cc8b8cc',
            id_rhomis_dataset: 'cd61facdcf970db01abdac65c5392aeb',
            id_form: 'test_form_id',
            id_proj: 'test_project_id',
            buffalo: null,
            bees: null
            ...
        },
        {
            id_unique: 'uuid:0b5207f3-db01-4668-bfed-dbe1a604e0ac',
            id_hh: '997f602e95e38cd40aed59aa4f7debad',
            id_rhomis_dataset: '52ebcf202d36fcb4cd18bf0ac6553c28',
            id_form: 'test_form_id',
            id_proj: 'test_project_id',
            buffalo: null,
            bees: null
            ...
        },
        ...
        ]
    }
```

The actual household level information is found in the `data` field.
Each object in the array represents a household, each key a column header, and each value the corresponding value for that household. Data sets can be indexed by project, form, and the "type" of data (e.g. indicator data, crop data etc...).

# Guidelines for Working

When making modification to the authentication api or the data api, please work on
your own feature branch. The "dev" branch contains the most recent changes you should work from.
I may continue making changes to the dev branch, so you should
regularly pull in changes from the upstream dev branch.

RHoMIS is a work in progress, so feel free to make changes to anything you
feel does not look right. Try to make small changes on feature branches
if possible and make a PR to merge them into "dev". Feel free to add
tests also.

If you have any questions, feel free to raise an issue 🙂
