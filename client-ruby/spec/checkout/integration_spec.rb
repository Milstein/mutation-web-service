require 'spec_helper'

describe 'integration' do
  let(:client) { Checkout::Client.build('http://localhost:9988', "test-team-#{Time.now.to_i}") }

  def strip(source)
    source = source.rstrip
    indent = source.scan(/^\s*/).min_by(&:length)
    source.gsub(/^#{indent}/, '') << "\n"
  end

  specify do
    expect(client.register).to be(client)

    expect(client.price_list).to eql(
      {
        'priceList' => {
          'entries'=> {
            'banana'=>{
              'itemCode' => 'banana',
              'unitPrice' => {
                'dollars' =>0,
                'cents'   =>25
              }
            }
          }
        }
      }
    )

    expect(client.current_requirements).to eql(
      'requirements' => strip(<<-TEXT
         Round 0

         GET the URL Checkout/Batch/your_team_name to retrieve a batch of baskets that you need to calculate the price of.

         Each basket has a unique ID
         In this round the batch will only contain a single basket
         In this round the basket will only contain a single item
         The item will be a banana and each banana costs 25c

         You PUT the result to /Checkout/Batch/your_team_name

         The JSON payload should look something like this:

             {"batch":{"baskets":{"1":{"dollars":0,"cents":75}}}}
              basket ID from batch ^
                        total cost of basket     ^          ^
                        (which you have calculated)
         TEXT
      )
    )

    expect(client.basket_batch).to eql(
      'batch' => {
        'baskets' => [
          {
            'basketId'=>1,
            'items'=> [
              {
                'itemCode' => 'banana',
                'quantity' => 1
              }
            ]
          }
        ]
      }
    )

    expect(client.current_score).to eql(
      'score' => 10
    )

    expect { client.submit_batch({}) }.to raise_error(Checkout::Client::Error::StatusCode) do |error|
      expect(error.message).to eql(strip(<<-TEXT))
        Unexpected response with code: 400
        {"batch"=>{"incorrectBaskets"=>{"1"=>"MissingBasket"}}}
      TEXT
    end
  end
end
