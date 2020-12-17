# an input file (for the test case we make one)
wget https://github.com/Informatievlaanderen/duet-generated/raw/master/report/doc/applicationprofile/cccev-ap/all-cccev-ap.jsonld
# the output of the html-generator
wget https://github.com/Informatievlaanderen/duet-generated/raw/master/report/doc/applicationprofile/cccev-ap/html-nj_en.json

DEFINITION = jq '.externals[] | select(."@id" == "http://fixme.com#Constraint" )|.definition' all-cccev-ap.jsonld
echo ${DEFINITION}

$SHELL