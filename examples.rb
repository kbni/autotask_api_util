# Yes, this is pretty nasty.

$LOAD_PATH.unshift(File.expand_path('./lib'))
$LOAD_PATH.unshift(File.expand_path('./autotask_api/lib'))

require '~/autotask_creds.rb'
require 'autotask_api'
require 'autotask_api_picklist'
require 'autotask_api_readonly'
require 'autotask_api_query2'

client = AutotaskAPI::Client.new do |c|
  c.basic_auth = AUTOTASK_CREDENTIALS
  c.wsdl = AUTOTASK_ENDPOINT
  c.log = false
end

client.get_picklist('Ticket')
client.get_picklist('Account')

atf = AutotaskQuery::AtFieldHelper.new
atq = AutotaskQuery::AtQueryHelper.new

ticket_dispatched = atf.QueueID == client.pl.Ticket_QueueID_2Dispatched
ticket_monitoring = atf.QueueID == client.pl.Ticket_QueueID_MonitoringAlert
ticket_open = (
  (atf.Status != client.pl.Ticket_Status_Complete) &
  (atf.Status != client.pl.Ticket_Status_Resolved)
)

q1 = atq.Ticket[ticket_dispatched & ticket_open]
q2 = atq.Ticket[ticket_monitoring & ticket_open]
q3 = atq.Ticket[ticket_open]

puts 'Dispatched queue: ' + client.entities_for(q1).count.to_s
puts 'Monitoring queue: ' + client.entities_for(q2).count.to_s
puts 'Any open tickets: ' + client.entities_for(q3).count.to_s
