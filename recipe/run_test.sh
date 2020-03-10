#!/usr/bin/env bash

# Run the test suite
python -c "import pygmo_plugins_nonfree; pygmo_plugins_nonfree.test.run_test_suite()"

# Stop the cluster. (this is commented out as XCodepy36 builds failed)
# ipcluster stop
