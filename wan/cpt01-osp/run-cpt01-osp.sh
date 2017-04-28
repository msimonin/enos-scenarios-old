#!/usr/bin/env bash

# Runner for the first wan experiment.
# Aim: Produce OSProfiler traces

set -x

# Experience Parameters
LATENCIES='0 10 25 50 100'
ENOS_GIT='https://github.com/rcherrueau/enos.git'
ENOS_REF='osprofiler'

EXP_HOME=$(pwd)
ENOS_HOME="${EXP_HOME}/enos"
WORKLOAD="${EXP_HOME}/workload"

trap 'exit' SIGINT


# Get Enos and setup the Virtual environment (if none)
if [ ! -d "${ENOS_HOME}" ]; then
  git clone "${ENOS_GIT}" --depth 1 --branch "${ENOS_REF}" "${ENOS_HOME}" 

  pushd "${ENOS_HOME}"
  virtualenv --python=python2.7 venv
  . venv/bin/activate
  pip install -r requirements.txt
  popd
fi

. "${ENOS_HOME}/venv/bin/activate"


# Run the experiment a first time to fill cache
pushd "${ENOS_HOME}"
python -m enos.enos up -f "${EXP_HOME}/reservation.yml" --force-deploy
python -m enos.enos os
python -m enos.enos init
python -m enos.enos bench --workload="${WORKLOAD}"
popd


# Run experiments with all latencies
for LTY in $LATENCIES; do
  OLD_RES_DIR=$(readlink "${ENOS_HOME}/current")
  NEW_RES_DIR="${EXP_HOME}/cpt01-osp-lat${LTY}"

  # Construct the repository for the new experiment
  cp -r "${OLD_RES_DIR}" "${NEW_RES_DIR}"

  # Update Enos environment with the location of the new experiment
  sed -i 's|'${OLD_RES_DIR}'|'${NEW_RES_DIR}'|' "${NEW_RES_DIR}/env"

  # Set the latency of the reservation.yml
  sed -i 's|default_delay: .\+|default_delay: '${LTY}'ms|' "${EXP_HOME}/reservation.yml"

  # Run Enos, setup latency, make test and bakcup results 
  pushd "${ENOS_HOME}"
  ENV=${NEW_RES_DIR}
  python -m enos.enos tc --env="${ENV}"
  python -m enos.enos tc --test --env="${ENV}"
  python -m enos.enos bench --workload="${WORKLOAD}" --env="${ENV}"
  python -m enos.enos backup --env="${ENV}"
  popd
done
