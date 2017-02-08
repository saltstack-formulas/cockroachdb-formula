require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'Pillar source: pillar.example' do
  describe service('cockroachdb') do
    it { should be_enabled }
    it { should be_running }
  end

  set :env, :COCKROACH_INSECURE => 'true', :COCKROACH_HOST => '192.168.50.11', :COCKROACH_PORT => '26300'

  context 'Given dbuser: devroach' do
    describe command('cockroach sql -e "SHOW USERS" --pretty=false') do
      its(:stdout) { should contain 'devroach' }
    end
  end

  context 'Given database: devroach' do
    describe command('cockroach sql -e "SHOW DATABASES" --pretty=false') do
      its(:stdout) { should contain 'devroach_sandbox' }
    end
  end

  context 'Given keep_initdb_sql: false' do
    describe file('/opt/cockroachdb/initdb.sql') do
      it { should_not exist }
    end
  end

  context 'Given a list of runtime_options' do
    describe process('cockroach') do
      its(:args) { should contain '--insecure=true --host=192.168.50.11 --port=26300 --http-host=192.168.50.11 --http-port=7070 --store=path=/etc/cockroachdb/data --log-dir=/var/log/cockroachdb' }
    end

    describe file('/etc/cockroachdb/data') do
      it { should be_a_directory }
      it { should be_owned_by 'cockroach' }
    end

    describe file('/var/log/cockroachdb') do
      it { should be_a_directory }
      it { should be_owned_by 'cockroach' }
    end
  end
end
