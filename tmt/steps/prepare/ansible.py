import tmt
import click

class PrepareAnsible(tmt.steps.prepare.PreparePlugin):
    """
    Prepare guest using ansible

    Single playbook config:

        prepare:
            how: ansible
            playbook: ansible/packages.yml

    Multiple playbooks config:

        prepare:
            how: ansible
            playbooks:
              - playbook/one.yml
              - playbook/two.yml
              - playbook/three.yml

    Use 'order' attribute to select in which order preparation should
    happen if there are multiple configs. Default order is '50'.
    Default order of required packages installation is '70'.
    """

    # Supported methods
    _methods = [tmt.steps.Method(name='ansible', doc=__doc__, order=50)]

    def __init__(self, step, data):
        """ Store plugin name, data and parent step """
        super().__init__(step, data)
        # Rename plural playbooks to singular
        if 'playbooks' in self.data:
            self.data['playbook'] = self.data.pop('playbooks')

    @classmethod
    def options(cls, how=None):
        """ Prepare command line options """
        return [
            click.option(
                '-p', '--playbook', metavar='PLAYBOOK', multiple=True,
                help='Path to an ansible playbook to run.')
            ] + super().options(how)

    def default(self, option, default=None):
        """ Return default data for given option """
        if option == 'playbook':
            return []
        return default

    def show(self):
        """ Show provided playbooks """
        super().show(['playbook'])

    def wake(self, data=None):
        """ Override options and wake up the guest """
        super().wake(['playbook'])

        # Convert to list if necessary
        tmt.utils.listify(self.data, keys=['playbook'])

    def go(self, guest):
        """ Prepare the guests """
        super().go()

        # Apply each playbook on the guest
        for playbook in self.get('playbook'):
            self.info('playbook', playbook, 'green')
            guest.ansible(playbook)
