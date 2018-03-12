defmodule Blockchain.Keys do

  @private_key <<9, 87, 46, 26, 159, 181, 222, 206, 109, 168, 141, 224, 238, 0, 152, 73>>

  def generate_public_key() do
    {pub_key, _} = :crypto.generate_key(:ecdh, :secp256k1, @private_key)
    pub_key
  end

  def sign_data(data) do
    :crypto.sign(:ecdsa, :sha256, data, [@private_key, :secp256k1])
  end

  def verify(data, signature, public_key) do
    :crypto.verify(:ecdsa, :sha256, data, signature, [public_key, :secp256k1])
  end
end
