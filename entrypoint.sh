#!/bin/sh

# -e  Exit immediately if a command exits with a non-zero status.
set -e

apt_get_install() {
    apt-get update
    apt-get install --auto-remove --force-yes --no-install-recommends --yes "$@"
    apt-get clean
    rm --force --recursive /var/lib/apt/lists/*
}

initialsetup() {
    echo "mayan: initialsetup()"

    ${MAYAN_BIN} initialsetup --force --no-dependencies
}

make_ready() {
    # Check if this is a new install, otherwise try to upgrade the existing
    # installation on subsequent starts.
    if [ ! -f $INSTALL_FLAG ]; then
        initialsetup
    else
        performupgrade
    fi
}

os_package_installs() {
    echo "mayan: os_package_installs()"
    if [ "${MAYAN_APT_INSTALLS}" ]; then
        DEBIAN_FRONTEND=noninteractive apt_get_install $MAYAN_APT_INSTALLS
    fi
}

performupgrade() {
    echo "mayan: performupgrade()"
    ${MAYAN_BIN} performupgrade --no-dependencies
}

pip_installs() {
    echo "mayan: pip_installs()"
    if [ "${MAYAN_PIP_INSTALLS}" ]; then
        ${MAYAN_PIP_BIN} install $MAYAN_PIP_INSTALLS
    fi
}

# Start execution here.
echo "mayan: starting entrypoint.sh"
INSTALL_FLAG=/var/lib/mayan/system/SECRET_KEY
CELERY_CONCURRENCY_ARGUMENT=--concurrency=
CELERY_MAX_MEMORY_PER_CHILD_ARGUMENT=--max-memory-per-child=
CELERY_MAX_TASKS_PER_CHILD_ARGUMENT=--max-tasks-per-child=

DEFAULT_USER_GID=1000
DEFAULT_USER_UID=1000

export MAYAN_USER_GID=${MAYAN_USER_GID:-${DEFAULT_USER_GID}}
export MAYAN_USER_UID=${MAYAN_USER_UID:-${DEFAULT_USER_UID}}

export MAYAN_ALLOWED_HOSTS='["*"]'
export MAYAN_BIN=/opt/mayan-edms/bin/mayan-edms.py
export MAYAN_INSTALL_DIR=/opt/mayan-edms
export MAYAN_PYTHON_BIN_DIR=/opt/mayan-edms/bin/
export MAYAN_MEDIA_ROOT=/var/lib/mayan
export MAYAN_SETTINGS_MODULE=${MAYAN_SETTINGS_MODULE:-mayan.settings.production}

# Set DJANGO_SETTINGS_MODULE to MAYAN_SETTINGS_MODULE to avoid two
# different environment variables for the same setting.
export DJANGO_SETTINGS_MODULE=${MAYAN_SETTINGS_MODULE}

export MAYAN_GUNICORN_BIN=${MAYAN_PYTHON_BIN_DIR}gunicorn
export MAYAN_GUNICORN_REQUESTS_JITTER=${MAYAN_GUNICORN_REQUESTS_JITTER:-50}
export MAYAN_GUNICORN_LIMIT_REQUEST_LINE=${MAYAN_GUNICORN_LIMIT_REQUEST_LINE:-4094}
export MAYAN_GUNICORN_MAX_REQUESTS=${MAYAN_GUNICORN_MAX_REQUESTS:-500}
export MAYAN_GUNICORN_WORKER_CLASS=${MAYAN_GUNICORN_WORKER_CLASS:-sync}
export MAYAN_GUNICORN_WORKERS=${MAYAN_GUNICORN_WORKERS:-3}
export MAYAN_GUNICORN_TIMEOUT=${MAYAN_GUNICORN_TIMEOUT:-120}
export MAYAN_PIP_BIN=${MAYAN_PYTHON_BIN_DIR}pip
export MAYAN_STATIC_ROOT=${MAYAN_INSTALL_DIR}/static

# Setup worker environment variables.

MAYAN_WORKER_A_CONCURRENCY=${MAYAN_WORKER_A_CONCURRENCY:-0}

if [ "$MAYAN_WORKER_A_CONCURRENCY" -eq 0 ]; then
    MAYAN_WORKER_A_CONCURRENCY=
else
    MAYAN_WORKER_A_CONCURRENCY="${CELERY_CONCURRENCY_ARGUMENT}${MAYAN_WORKER_A_CONCURRENCY}"
fi
export MAYAN_WORKER_A_CONCURRENCY

MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD=${MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD:-300000}

if [ "$MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD=
else
    MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD="${CELERY_MAX_MEMORY_PER_CHILD_ARGUMENT}${MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD}"
fi
export MAYAN_WORKER_A_MAX_MEMORY_PER_CHILD

MAYAN_WORKER_A_MAX_TASKS_PER_CHILD=${MAYAN_WORKER_A_MAX_TASKS_PER_CHILD:-100}

if [ "$MAYAN_WORKER_A_MAX_TASKS_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_A_MAX_TASKS_PER_CHILD=
else
    MAYAN_WORKER_A_MAX_TASKS_PER_CHILD="${CELERY_MAX_TASKS_PER_CHILD_ARGUMENT}${MAYAN_WORKER_A_MAX_TASKS_PER_CHILD}"
fi
export MAYAN_WORKER_A_MAX_TASKS_PER_CHILD

MAYAN_WORKER_B_CONCURRENCY=${MAYAN_WORKER_B_CONCURRENCY:-0}

if [ "$MAYAN_WORKER_B_CONCURRENCY" -eq 0 ]; then
    MAYAN_WORKER_B_CONCURRENCY=
else
    MAYAN_WORKER_B_CONCURRENCY="${CELERY_CONCURRENCY_ARGUMENT}${MAYAN_WORKER_B_CONCURRENCY}"
fi
export MAYAN_WORKER_B_CONCURRENCY

MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD=${MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD:-300000}

if [ "$MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD=
else
    MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD="${CELERY_MAX_MEMORY_PER_CHILD_ARGUMENT}${MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD}"
fi
export MAYAN_WORKER_B_MAX_MEMORY_PER_CHILD

MAYAN_WORKER_B_MAX_TASKS_PER_CHILD=${MAYAN_WORKER_B_MAX_TASKS_PER_CHILD:-100}

if [ "$MAYAN_WORKER_B_MAX_TASKS_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_B_MAX_TASKS_PER_CHILD=
else
    MAYAN_WORKER_B_MAX_TASKS_PER_CHILD="${CELERY_MAX_TASKS_PER_CHILD_ARGUMENT}${MAYAN_WORKER_B_MAX_TASKS_PER_CHILD}"
fi
export MAYAN_WORKER_B_MAX_TASKS_PER_CHILD

MAYAN_WORKER_C_CONCURRENCY=${MAYAN_WORKER_C_CONCURRENCY:-0}

if [ "$MAYAN_WORKER_C_CONCURRENCY" -eq 0 ]; then
    MAYAN_WORKER_C_CONCURRENCY=
else
    MAYAN_WORKER_C_CONCURRENCY="${CELERY_CONCURRENCY_ARGUMENT}${MAYAN_WORKER_C_CONCURRENCY}"
fi
export MAYAN_WORKER_C_CONCURRENCY

MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD=${MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD:-300000}

if [ "$MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD=
else
    MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD="${CELERY_MAX_MEMORY_PER_CHILD_ARGUMENT}${MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD}"
fi
export MAYAN_WORKER_C_MAX_MEMORY_PER_CHILD

MAYAN_WORKER_C_MAX_TASKS_PER_CHILD=${MAYAN_WORKER_C_MAX_TASKS_PER_CHILD:-100}

if [ "$MAYAN_WORKER_C_MAX_TASKS_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_C_MAX_TASKS_PER_CHILD=
else
    MAYAN_WORKER_C_MAX_TASKS_PER_CHILD="${CELERY_MAX_TASKS_PER_CHILD_ARGUMENT}${MAYAN_WORKER_C_MAX_TASKS_PER_CHILD}"
fi
export MAYAN_WORKER_C_MAX_TASKS_PER_CHILD

MAYAN_WORKER_D_CONCURRENCY=${MAYAN_WORKER_D_CONCURRENCY:-1}

if [ "$MAYAN_WORKER_D_CONCURRENCY" -eq 0 ]; then
    MAYAN_WORKER_D_CONCURRENCY=
else
    MAYAN_WORKER_D_CONCURRENCY="${CELERY_CONCURRENCY_ARGUMENT}${MAYAN_WORKER_D_CONCURRENCY}"
fi
export MAYAN_WORKER_D_CONCURRENCY

MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD=${MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD:-300000}

if [ "$MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD=
else
    MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD="${CELERY_MAX_MEMORY_PER_CHILD_ARGUMENT}${MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD}"
fi
export MAYAN_WORKER_D_MAX_MEMORY_PER_CHILD

MAYAN_WORKER_D_MAX_TASKS_PER_CHILD=${MAYAN_WORKER_D_MAX_TASKS_PER_CHILD:-10}

if [ "$MAYAN_WORKER_D_MAX_TASKS_PER_CHILD" -eq 0 ]; then
    MAYAN_WORKER_D_MAX_TASKS_PER_CHILD=
else
    MAYAN_WORKER_D_MAX_TASKS_PER_CHILD="${CELERY_MAX_TASKS_PER_CHILD_ARGUMENT}${MAYAN_WORKER_D_MAX_TASKS_PER_CHILD}"
fi
export MAYAN_WORKER_D_MAX_TASKS_PER_CHILD


if mount | grep '/dev/shm' > /dev/null; then
    export MAYAN_GUNICORN_TEMPORARY_DIRECTORY="--worker-tmp-dir /dev/shm"
else
    export MAYAN_GUNICORN_TEMPORARY_DIRECTORY=
fi

# Allow importing of user setting modules.
export PYTHONPATH=$PYTHONPATH:$MAYAN_MEDIA_ROOT

if [ "${MAYAN_DOCKER_SCRIPT_PRE_SETUP}" ]; then
    eval "${MAYAN_DOCKER_SCRIPT_PRE_SETUP}"
fi

${MAYAN_PYTHON_BIN_DIR}python3 /usr/local/bin/wait.py ${MAYAN_DOCKER_WAIT}
os_package_installs || true
pip_installs || true

if [ "${MAYAN_DOCKER_SCRIPT_POST_SETUP}" ]; then
    eval "${MAYAN_DOCKER_SCRIPT_POST_SETUP}"
fi

case "$1" in

run_all)
    make_ready
    /usr/local/bin/run_all.sh
    ;;

run_celery)
    shift
    /usr/local/bin/run_celery.sh "${@}"
    ;;

run_command)
    shift
    ${MAYAN_BIN} ${@}
    ;;

run_frontend)
    /usr/local/bin/run_frontend.sh
    ;;

run_initialsetup)
    initialsetup
    ;;

run_performupgrade)
    performupgrade
    ;;

run_initialsetup_or_performupgrade)
    make_ready
    ;;

run_tests)
    make_ready
    shift
    /usr/local/bin/run_tests.sh "${@}"
    ;;

run_worker)
    shift
    /usr/local/bin/run_worker.sh "${@}"
    ;;

*)
    "$@"
    ;;

esac