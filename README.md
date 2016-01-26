# autotask_api_util

Collection of utilities to enhance [scoop's Ruby API wrapper](https://github.com/scoop/autotask_api) for the Autotask WebService API

I have not simply forked autotask_api for a few reasons:

* My days working with Autotask are numbered
* This is my first time using Ruby, I'm not competent enough
* I have not had time to thoroughly test any of this code

## Features

* autotask_api_picklist.rb - Converts picklist names to IDs (for queries)
* autotask_api_query2.rb - Somewhat enhanced query builder
* autotask_api_readonly.rb - Disables AutotaskAPI::Client's update/create methods

## Examples

### autotask_api_readonly.rb Example

    require 'autotask_api'
    require 'autotask_api_readonly'
    client = AutotaskAPI::Client.new do |c|
      c.basic_auth = ['user@example.com', 'mypassword']
      c.wsdl = 'https://webservices.autotask.net/atservices/1.5/atws.wsdl'
    end
    client.update(update_obj)

the above will output: 

    blocked AutotaskAPI.update

### autotask_api_picklist.rb Example

    require 'autotask_api'
    require 'autotask_api_picklist'
    client = AutotaskAPI::Client.new do |c|
      c.basic_auth = ['user@example.com', 'mypassword']
      c.wsdl = 'https://webservices.autotask.net/atservices/1.5/atws.wsdl'
    end
    client.get_picklist('Ticket')
    puts client.pl.Ticket_Status_Inactivity

the above will output: 

    16

### autotask_api_query2.rb Example

    require 'autotask_api'
    require 'autotask_api_picklist'
    require 'autotask_api_query2'
     
    client = AutotaskAPI::Client.new do |c|
      c.basic_auth = ['user@example.com', 'mypassword']
      c.wsdl = 'https://webservices.autotask.net/atservices/1.5/atws.wsdl'
    end
     
    atf = AutotaskQuery::AtFieldHelper.new(false)
    atq = AutotaskQuery::AtQueryHelper.new()

    ticket_dispatched = atf.QueueID == client.pl.Ticket_QueueID_2Dispatched
    ticket_open = (atf.Status != client.pl.Ticket_Status_Complete)&(atf.Status != client.pl.Ticket_Status_Resolved)
    new_query = atq.Ticket[ticket_dispatched&ticket_open]
    puts new_query

will output:

    <sXML><![CDATA[<queryxml>
      <entity>Ticket</entity>
      <query>
        <condition>
          <field>Queue<expression op="Equals">8</expression></field>
          <condition>
            <field>Status<expression op="NotEqual">5</expression></field>
            <field>Status<expression op="NotEqual">14</expression></field>
          </condition>
        </condition>
      </query>
    </queryxml>]]></sXML>
    
so..

    res = client.entities_for(new_query)
    puts res.count
    
should hopefully return..

    7

