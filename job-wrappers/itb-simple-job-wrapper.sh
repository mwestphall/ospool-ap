#!/bin/bash

# If we're inside Singularity, then make sure we set HOME and IWD correctly.
# (N.B. - it's not 100% clear that this is needed.  Original comments around
# this note that `--pwd` is unreliable in some versions of Singularity but not
# when this was fixed.
if [ ! -z "$SINGULARITY_NAME" ]; then
    [[ -d /srv ]] && cd /srv
    export HOME=/srv
    export OSG_WN_TMP=/tmp
else
    # OSPool: set up TMPDIR to be in the job dir; try to avoid /tmp at
    # sites as some users tend to fill it up and disrupt the host.
    #
    # This is not done when inside Singularity as the equivalent is accomplished
    # via bind mounts.
    if [ "x$_CONDOR_SCRATCH_DIR" != "x" ]; then
        TMPDIR="$_CONDOR_SCRATCH_DIR/.local-tmp"
    else
        TMPDIR=$(pwd)"/.local-tmp"
    fi
    export TMPDIR
    export OSG_WN_TMP=$TMPDIR
    mkdir -p $TMPDIR

fi

# Always make sure we have a reasonable PATH if it is not otherwise set.
# Should be valid both inside and outside the container.
export PATH=$PATH
[[ -z "$PATH" ]] && export PATH="/usr/local/bin:/usr/bin:/bin"

# GlideinWMS utility files and libraries - particularly condor_chirp
if [[ -d "$PWD/.gwms.d/bin" ]]; then
    # This includes the portable Python only condor_chirp
    export PATH="$PWD/$GWMS_SUBDIR/bin:$PATH"
fi

# Some java programs have seen problems with the timezone in our containers.
# If not already set, provide a default TZ
[[ -z "$TZ" ]] && export TZ="UTC"

exec "$@"
