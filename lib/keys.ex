defmodule Blockchain.Keys do

  @private_key1 "F98B04BC42B472ACC18829FAA979FBA3"
  @private_key2 "7DE02990657F7DA9A0F7008957461A59"
  @private_key3 "10CAA0396F838C7C4F58575B459C42FD"
  @miner_private_key "09572E1A9FB5DECE6DA88DE0EE009849"

  def generate_public_key(private_key) do
    {:ok, private_key} = Base.decode16(private_key)
    {pub_key, _} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    pub_key |> Base.encode16()
    # pub_key |> Base.encode16()
  end

end
