#!/bin/bash

if [ -f /tmp/project_id ]; then 
    export PROJECT_ID=$(cat /tmp/project_id)
 fi

if [ "$PROJECT_ID" == "" ]; then 
    echo "PROJECT_ID is undefined. Please set a PROJECT_ID env variable corresponding to a launchpad project."
    exit 1
fi

BASEDIR=$(dirname $0)

if [ "$DASHING_DIR" == "" ]; then 
    DASHING_DIR=/opt/lpprmd/dashing
fi

if [ ! -d $DASHING_DIR ] || [ ! -d $DASHING_DIR/dashboards ]; then
    echo "$DASHING_DIR is not a valid dashing directory."
    exit 1
fi

SERIES_LIST=$($BASEDIR/series-list.py)

if [ $? -ne 0 ]; then 
    echo "error: $SERIES_LIST"
    exit 1
else
    export SERIES_IDS=$(echo $SERIES_LIST | tr ' ' '\n' | cut -d\; -f1 | tr '\n' ',')
    erb $BASEDIR/templates/project.erb > $DASHING_DIR/dashboards/$PROJECT_ID.erb
    for series in $SERIES_LIST; do
        series_id=$(echo $series | cut -d";" -f1)
        export MILESTONES_IDS=$(echo $series | cut -d";" -f2)
        erb $BASEDIR/templates/series-detailled-dashboard-template.erb > $DASHING_DIR/dashboards/${PROJECT_ID}_$series_id.erb
    done
fi
