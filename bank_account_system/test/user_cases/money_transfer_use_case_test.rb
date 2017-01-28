require 'test_helper'

class MoneyTransferUseCaseTest < ActiveSupport::TestCase

    test "execute money transfer for valid origin and destination account ids" do

      origin_account_id = FactoryGirl.create(:account, 
                                             balance: 100, 
                                             user: FactoryGirl.create(:user)).id
      destination_account_id = FactoryGirl.create(:account, 
                                                  balance: 30, 
                                                  user: FactoryGirl.create(:user)).id

      money_transfer_service = MoneyTransferUseCase.new(
                                origin_account_id: origin_account_id, 
                                destination_account_id: destination_account_id, 
                                amount: 50)
      money_transfer_service.execute

      assert Account.find_by_id(origin_account_id).balance == 50
      assert Account.find_by_id(destination_account_id).balance == 80
    end


    test "raise error when origin account id is inexistent" do
      destination_account_id = FactoryGirl.create(:account, 
                                                  balance: 30, 
                                                  user: FactoryGirl.create(:user)).id

      params = { origin_account_id: 99999, destination_account_id: destination_account_id, amount: 20  }

      assert_raises(InexistentOriginAccountError) { MoneyTransferUseCase.new(params).execute }
    end


    test "raise error when origin account id is nil" do
      destination_account_id = FactoryGirl.create(:account, 
                                                  balance: 30, 
                                                  user: FactoryGirl.create(:user)).id

      params = { origin_account_id: nil, destination_account_id: destination_account_id, amount: 20  }

      assert_raises(InexistentOriginAccountError) { MoneyTransferUseCase.new(params).execute }
    end


    test "raise error when destination account id is inexistent" do
      origin_account_id = FactoryGirl.create(:account, 
                                             balance: 100, 
                                             user: FactoryGirl.create(:user)).id

      params = { origin_account_id: origin_account_id, destination_account_id: 99999, amount: 20  }

      assert_raises(InexistentDestinationAccountError) { MoneyTransferUseCase.new(params).execute }
    end


    test "raise error when destination account id is nil" do
      origin_account_id = FactoryGirl.create(:account, 
                                             balance: 100, 
                                             user: FactoryGirl.create(:user)).id
  
      params = { origin_account_id: origin_account_id, destination_account_id: 99999, amount: 20  }

      assert_raises(InexistentDestinationAccountError) { MoneyTransferUseCase.new(params).execute }
    end


    test "raise error when money transfer object returns errors" do

      origin_account_id = FactoryGirl.create(:account, 
                                             balance: 100, 
                                             user: FactoryGirl.create(:user)).id
      destination_account_id = FactoryGirl.create(:account, 
                                                  balance: 30, 
                                                  user: FactoryGirl.create(:user)).id
      amount = 20

      params = { origin_account_id: origin_account_id, destination_account_id: destination_account_id, amount: amount  }

      class RandomMoneyTransferError < StandardError
      end

      #PAREI AQUI !!! - TAREFAS SUGERIDAS EM ORDEM:
      #* rename MoneyTransferUseCase to MoneyTransferUseCase 
      #* rename folder from services to use_cases
      #* rename MoneyTransferUseCaseTest to MoneyTransferUseCaseTest
      #* rename folder from test/services to test/use_cases

      mock_money_transfer = Minitest::Mock.new
      mock_money_transfer.expect :nil?, false
      mock_money_transfer.expect(:transfer, nil) do |amount| 
        raise RandomMoneyTransferError 
      end

      money_transfer_service = MoneyTransferUseCase.new(params)
      money_transfer_service.money_transfer = mock_money_transfer

      assert_raises(RandomMoneyTransferError) { money_transfer_service.execute }
      mock_money_transfer.verify

    end

end