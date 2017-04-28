#!/usr/bin/env bash

# Runner for the third wan experiment.
# Aim: TODO

set -x

# Configuration Parameters
ENOS_HOME="/home/${USER}/enos"
EXP_HOME=$(pwd)
WORKLOAD="${EXP_HOME}/workload-cpt40"

# Note: ANSIBLE_CONFIG limits the number parallel ssh execution to 25
# otherwise Docker registry produces timeout 
# during containers pulling.

trap 'exit' SIGINT


# Setup the Virtual environment (if none)
pushd "${ENOS_HOME}"
if [ ! -d venv ]; then
  virtualenv --python=python2.7 venv
  . venv/bin/activate
  pip install -r requirements.txt
fi

. venv/bin/activate
popd


# Run the experiment a first time to fill cache
pushd "${ENOS_HOME}"
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos up -f "${EXP_HOME}/reservation-cpt40.yml" --force-deploy
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos os
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos init
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos bench --workload="${WORKLOAD}"
popd


# Run experiment a second time and save results
OLD_RES_DIR=$(readlink "${ENOS_HOME}/current")
NEW_RES_DIR="${EXP_HOME}/cpt40"

# Construct the repository for the new experiment
cp -r "${OLD_RES_DIR}" "${NEW_RES_DIR}"

# Update the environment with the location of the new experiment
sed -i 's|'${OLD_RES_DIR}'|'${NEW_RES_DIR}'|' "${NEW_RES_DIR}/env"

# Run Enos, set latencies, make test and backup results
pushd "${ENOS_HOME}"
ENV=${NEW_RES_DIR}
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos tc --env="${ENV}"
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos tc --test --env="${ENV}"
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos bench --workload="${WORKLOAD}" --env="${ENV}"
ANSIBLE_CONFIG="${EXP_HOME}/ansible.cfg" python -m enos.enos backup --env="${ENV}"
popd

