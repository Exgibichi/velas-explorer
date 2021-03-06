defmodule Explorer.Staking.ContractReader do
  @moduledoc """
  Routines for batched fetching of information from POSDAO contracts
  """

  alias Explorer.SmartContract.Reader

  def global_requests do
    [
      min_candidate_stake: {:staking, "candidateMinStake", []},
      min_delegator_stake: {:staking, "delegatorMinStake", []},
      epoch_number: {:staking, "stakingEpoch", []},
      epoch_end_block: {:staking, "stakingEpochEndBlock", []},
      active_pools: {:staking, "getPools", []},
      inactive_pools: {:staking, "getPoolsInactive", []},
      pools_likely: {:staking, "getPoolsToBeElected", []},
      pools_likelihood: {:staking, "getPoolsLikelihood", []},
      validators: {:validator_set, "getValidators", []}
    ]
  end

  def pool_staking_requests(staking_address) do
    [
      mining_address_hash: {:validator_set, "miningByStakingAddress", [staking_address]},
      is_active: {:staking, "isPoolActive", [staking_address]},
      active_delegators: {:staking, "poolDelegators", [staking_address]},
      inactive_delegators: {:staking, "poolDelegatorsInactive", [staking_address]},
      staked_amount: {:staking, "stakeAmountTotal", [staking_address]},
      self_staked_amount: {:staking, "stakeAmount", [staking_address, staking_address]},
      block_reward: {:block_reward, "validatorRewardPercent", [staking_address]}
    ]
  end

  def pool_mining_requests(mining_address) do
    [
      is_validator: {:validator_set, "isValidator", [mining_address]},
      was_validator_count: {:validator_set, "validatorCounter", [mining_address]},
      is_banned: {:validator_set, "isValidatorBanned", [mining_address]},
      banned_until: {:validator_set, "bannedUntil", [mining_address]},
      was_banned_count: {:validator_set, "banCounter", [mining_address]}
    ]
  end

  def delegator_requests(pool_address, delegator_address) do
    [
      stake_amount: {:staking, "stakeAmount", [pool_address, delegator_address]},
      ordered_withdraw: {:staking, "orderedWithdrawAmount", [pool_address, delegator_address]},
      max_withdraw_allowed: {:staking, "maxWithdrawAllowed", [pool_address, delegator_address]},
      max_ordered_withdraw_allowed: {:staking, "maxWithdrawOrderAllowed", [pool_address, delegator_address]},
      ordered_withdraw_epoch: {:staking, "orderWithdrawEpoch", [pool_address, delegator_address]}
    ]
  end

  def perform_requests(requests, contracts, abi) do
    requests
    |> generate_requests(contracts)
    |> Reader.query_contracts(abi)
    |> parse_responses(requests)
  end

  def perform_grouped_requests(requests, keys, contracts, abi) do
    requests
    |> List.flatten()
    |> generate_requests(contracts)
    |> Reader.query_contracts(abi)
    |> parse_grouped_responses(keys, requests)
  end

  defp generate_requests(functions, contracts) do
    Enum.map(functions, fn {_, {contract, function, args}} ->
      %{
        contract_address: contracts[contract],
        function_name: function,
        args: args
      }
    end)
  end

  defp parse_responses(responses, requests) do
    requests
    |> Enum.zip(responses)
    |> Enum.into(%{}, fn {{key, _}, {:ok, response}} ->
      case response do
        [item] -> {key, item}
        items -> {key, items}
      end
    end)
  end

  defp parse_grouped_responses(responses, keys, grouped_requests) do
    {grouped_responses, _} = Enum.map_reduce(grouped_requests, responses, &Enum.split(&2, length(&1)))

    [keys, grouped_requests, grouped_responses]
    |> Enum.zip()
    |> Enum.into(%{}, fn {key, requests, responses} ->
      {key, parse_responses(responses, requests)}
    end)
  end
end
