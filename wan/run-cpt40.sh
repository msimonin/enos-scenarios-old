#!/usr/bin/env bash

# Runner for the third wan experiment.
# Aim: TODO

set -x

# Configuration Parameters
ENOS_HOME="/home/${USER}/enos"
EXP_HOME=$(pwd)
WORKLOAD="${EXP_HOME}/workload-cpt40"

trap 'exit' SIGINT

# Run the experiment a first time to fill cache
pushd "${ENOS_HOME}"
python -m enos.enos up -f "${EXP_HOME}/reservation-cpt40.yml" # --force-deploy
python -m enos.enos os
python -m enos.enos init
python -m enos.enos bench --workload="${WORKLOAD}"
popd

# Run experiment a second time and save results
OLD_RES_DIR=$(readlink "${ENOS_HOME}/current")
NEW_RES_DIR="${EXP_HOME}/wan-cpt40"

# Construct the repository for the new experiment
cp -r "${OLD_RES_DIR}" "${NEW_RES_DIR}"
rm "${ENOS_HOME}/current"
ln -s "${NEW_RES_DIR}" "${ENOS_HOME}/current"

# Setup the environment with the location of the new folder
sed -i 's|'${OLD_RES_DIR}'|'${NEW_RES_DIR}'|' "${NEW_RES_DIR}/env"

# Run Enos, set latencies, make test and backup results
pushd "${ENOS_HOME}"
ENV=${NEW_RES_DIR}
python -m enos.enos tc --env="${ENV}"
python -m enos.enos tc --test --env="${ENV}"
python -m enos.enos bench --workload="${WORKLOAD}" --env="${ENV}"
python -m enos.enos backup --env="${ENV}"
popd
