#!/usr/bin/env bash

# Runner for the second wan experiment.
# Aim: TODO

set -x

# Configuration Parameters
LATENCIES='0 10 25 50 100'
ENOS_HOME="/home/${USER}/enos"
EXP_HOME=$(pwd)
WORKLOAD="${EXP_HOME}/workload-cpt10"

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
python -m enos.enos up -f "${EXP_HOME}/reservation-cpt10.yml" --force-deploy
python -m enos.enos os
python -m enos.enos init
python -m enos.enos bench --workload="${WORKLOAD}"
popd


# Run experiments with different latencies 
for LTY in $LATENCIES; do
  OLD_RES_DIR=$(readlink "${ENOS_HOME}/current")
  NEW_RES_DIR="${EXP_HOME}/wan-cpt10-lat${LTY}"

  # Construct the repository for the new experiment
  cp -r "${OLD_RES_DIR}" "${NEW_RES_DIR}"
  rm "${ENOS_HOME}/current"
  ln -s "${NEW_RES_DIR}" "${ENOS_HOME}/current"

  # Setup the environment with the location of the new folder
  sed -i 's|'${OLD_RES_DIR}'|'${NEW_RES_DIR}'|' "${NEW_RES_DIR}/env"

  # Set the latency of the reservation.yml
  sed -i 's|default_delay: .\+|default_delay: '${LTY}'ms|' "${EXP_HOME}/reservation-cpt10.yml"

  # Run Enos, setup latency, make test and backup results
  pushd "${ENOS_HOME}"
  ENV=${NEW_RES_DIR}
  python -m enos.enos tc --env="${ENV}"
  python -m enos.enos tc --test --env="${ENV}"
  python -m enos.enos bench --workload="${WORKLOAD}" --env="${ENV}"
  python -m enos.enos backup --env="${ENV}"
  popd
done
