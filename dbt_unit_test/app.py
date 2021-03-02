"""dbt_unit_test.app: CLI for running unit tests on dbt macros."""

import os, sys
import click
import yaml


from .log_setup import console, LOG_LEVELS
from . import operations as ops

@click.group()
def dut():
    pass

@click.command()
def init():
    if not os.path.exists('dbt_unit_test.yml'):
        with open('dbt_unit_test.yml', 'w') as conf_file:
            conf_file.write(ops.render_template('default_config.yml'))
    click.secho('Please set up a dbt profile called "unit_test".', fg='blue')
    

@click.command()
@click.option('--tests', help='tests to run.')
@click.option('--batches', default=2, help='batches to run.')
@click.option('--log-level', default='info', help='Set log level.')
def run(tests, batches, log_level):
    """Run unit tests on a dbt models."""
    # use defaults if there is no config file.

    with open('dbt_unit_test.yml', 'r') as conf_file:
        config = yaml.safe_load(conf_file.read())

    console.setLevel(LOG_LEVELS.get(log_level, 'info'))

    profile = ['--profile', config['unit_test_profile']]

    model = ['--model']
    model += [f'+tag:{test}+' for test in tests.split(',')] if tests else ['+tag:unit_test+']
    select = ['--select'] + model[1:]

    ops.remove_files(**config)
    ops.copy_files(**config)

    errors = 0

    errors += ops.dbt_sp(['dbt', 'seed', '--full-refresh'] + select + profile)

    for batch in range(1, batches+1):
        vars_ = []
        if batch < batches:
            vars_ += ['--vars', f"batch: {batch}"]

        if batch == batches:
            vars_ += ['--full-refresh']

        errors += ops.dbt_sp(['dbt', 'run'] + model + profile + vars_)

    errors += ops.dbt_sp(['dbt', 'test'] + model + profile)

    if log_level != 'debug':
        ops.remove_files(**config)

    if errors != 0:
        sys.exit(os.EX_SOFTWARE)
        
dut.add_command(run)
dut.add_command(init)

if __name__ == '__main__':
    dut()