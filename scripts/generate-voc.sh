#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CONFIGDIR=$3
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
PRIMELANGUAGE=${4-'nl'}
GOALLANGUAGE=${5-'en'}

echo "generate-voc: starting with $1 $2 $3"

#############################################################################################
make_jsonld() {
    local FILE=$1 
    local INPUT=$2
    local TARGET=$3
    local CONFIGDIR=$4
    local LANGUAGE=$5
    local RLINE=$6
    local SLINE=$7
    mkdir -p /tmp/${FILE}
    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .mergefile')
    MERGEDJSONLD=${RLINE}/translation/$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)

    if ! node /app/render-voc.js -i ${MERGEDJSONLD} -o ${TARGET} -l ${LANGUAGE} -n /tmp/${FILE}/ontology -d ${CONFIGDIR}/ontology.defaults.json -c ${CONFIGDIR}/context
    then
        echo "RENDER-DETAILS(voc-languageaware): See ${OUTREPORT} for the details"
        exit -1
    else
        echo "RENDER-DETAILS(voc-languageaware): saved to ${TARGET}"
    fi

}
#############################################################################################

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line} 
    RLINE=${TARGETDIR}/report/${line}   
    echo "Processing line: ${SLINE} => ${TLINE} ${RLINE}"
    if [ -d "${SLINE}" ]
    then
            for i in ${SLINE}/*.jsonld
            do
                echo "generate-voc: convert $i to RDF"
                BASENAME=$(basename $i .jsonld)
                OUTFILE=${BASENAME}.ttl
                REPORT=${RLINE}/${BASENAME}.ttl-report

                mkdir -p ${TLINE}/voc
                make_jsonld $BASENAME $i ${SLINE}/selected_${PRIMELANGUAGE}.jsonld ${CONFIGDIR} ${PRIMELANGUAGE} ${RLINE} ${SLINE}
                make_jsonld $BASENAME $i ${SLINE}/selected_${GOALLANGUAGE}.jsonld ${CONFIGDIR} ${GOALLANGUAGE} ${RLINE} ${SLINE} || exit 1
                cp ${SLINE}/selected_${PRIMELANGUAGE}.jsonld ${TLINE}/voc/${BASENAME}_${PRIMELANGUAGE}.jsonld
                cp ${SLINE}/selected_${GOALLANGUAGE}.jsonld ${TLINE}/voc/${BASENAME}_${GOALLANGUAGE}.jsonld
#                if ! rdf serialize --input-format jsonld --processingMode json-ld-1.1 ${SLINE}/selected.jsonld --output-format turtle -o ${TLINE}/voc/$BASENAME.ttl 2>&1 | tee ${REPORT}
#                then
#                    exit 1
#                fi
            done
    else
	    echo "Error: ${SLINE}"
    fi
done



