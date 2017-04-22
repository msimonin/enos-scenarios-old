#!/usr/bin/env bash
LATENCIES='0 10 25 50 100'
ENOS_HOME='~/enos'
EXP_HOME=$(pwd)

for LTY in $LATENCIES; do
  OLD_RES_DIR=$(readlink "${ENOS_HOME}/current")
  NEW_RES_DIR="${EXP_HOME}/wan-osp-cpt01-lat${LTY}"

  # Construct the repository for the new experiment
  mkdir "${NEW_RES_DIR}"
  cp -r "${OLD_RES_DIR}/" "${NEW_RES_DIR}"
  ln -s --force "${NEW_RES_DIR}" "${ENOS_HOME}/current"

  # Setup the environment with the location of the new folder
  sed -i "s/${OLD_RES_DIR}/${NEW_RES_DIR}/" "${NEW_RES_DIR}/env"

  # Set the latency of the reservation.yml
  sed -i "s/default_delay: .+/default_delay: ${LTY}ms/" "${EXP_HOME}/reservation-wan-osp-cpt01-lat000-100.yml"

  # Run Enos with all
  pushd "${ENOS_HOME}"
  ENV=${NEW_RES_DIR}
  python -m enos.enos tc --env="${ENV}"
  python -m enos.enos tc --test --env="${ENV}"
  python -m enos.enos bench --workload="${EXP_HOME}/workload" --env="${ENV}"
  python -m enos.enos backup --env="${ENV}"
  popd
done
