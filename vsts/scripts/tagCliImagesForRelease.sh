#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

set -o pipefail

declare -r REPO_DIR=$( cd $( dirname "$0" ) && cd .. && cd .. && pwd )
source $REPO_DIR/build/__variables.sh

declare -r outPmeFile="$BUILD_ARTIFACTSTAGINGDIRECTORY/drop/images/oryxprodmcr-cli-images-mcr.txt"
declare -r outNonPmeFile="$BUILD_ARTIFACTSTAGINGDIRECTORY/drop/images/oryxmcr-cli-images-mcr.txt"
declare -r sourceImageRepo="oryxdevmcr.azurecr.io/public/oryx"
declare -r prodPmeImageRepo="oryxprodmcr.azurecr.io/public/oryx"
declare -r prodNonPmeImageRepo="oryxmcr.azurecr.io/public/oryx"

sourceBranchName=$BUILD_SOURCEBRANCHNAME

if [ -f "$outPmeFile" ]; then
    rm $outPmeFile
fi

if [ -f "$outNonPmeFile" ]; then
    rm $outNonPmeFile
fi

cliImage="$sourceImageRepo/cli:$BUILD_DEFINITIONNAME.$RELEASE_TAG_NAME"
cliBusterImage="$sourceImageRepo/cli-buster:$BUILD_DEFINITIONNAME.$RELEASE_TAG_NAME"
echo "Pulling CLI image '$cliImage'..."
docker pull "$cliImage"

echo "Retagging CLI image for $prodPmeImageRepo with '$RELEASE_TAG_NAME'..."
echo "$prodPmeImageRepo/cli:$RELEASE_TAG_NAME">>"$outPmeFile"
docker tag "$cliImage" "$prodPmeImageRepo/cli:$RELEASE_TAG_NAME"

echo "Pulling CLI buster image '$cliBusterImage'..."
docker pull "$cliBusterImage"

echo "Retagging CLI buster image for $prodPmeImageRepo with '$RELEASE_TAG_NAME'..."
echo "$prodPmeImageRepo/cli-buster:$RELEASE_TAG_NAME">>"$outPmeFile"
docker tag "$cliBusterImage" "$prodPmeImageRepo/cli-buster:$RELEASE_TAG_NAME"

if [ "$sourceBranchName" == "master" ]; then
    echo "Retagging CLI image with 'stable'..."

    docker tag "$cliImage" "$prodPmeImageRepo/cli:stable"
    echo "$prodPmeImageRepo/cli:stable">>"$outPmeFile"

    docker tag "$cliBusterImage" "$prodPmeImageRepo/cli-buster:stable"
    echo "$prodPmeImageRepo/cli-buster:stable">>"$outPmeFile"
else
    echo "Not creating 'stable' or 'latest' tags as source branch is not 'master'. Current branch is $sourceBranchName"
fi

echo "printing pme tags from $outPmeFile"
cat $outPmeFile
echo -------------------------------------------------------------------------------
echo "printing non-pme tags from $outNonPmeFile"
cat $outNonPmeFile
echo -------------------------------------------------------------------------------