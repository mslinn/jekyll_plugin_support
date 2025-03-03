# Supports one chain at a time
module SendChain
  # See https://stackoverflow.com/a/79333706/553865
  # This method can be called directly if no methods in the chain require arguments
  # Does not use any external state
  def send_chain(chain)
    Array(chain).inject(self) { |o, a| o.send(*a) }
  end

  # Saves @chain structure containing :placeholders for arguments to be supplied later
  # Call when a different chain with :placeholders is desired
  def new_chain(chain)
    abort "new_chain error: chain must be an array ('#{chain}' was an #{chain.class.name})" \
      unless chain.instance_of?(Array)
    @chain = chain
  end

  # Call after new_chain, to evaluate @chain with values
  def substitute_and_send_chain_with(values)
    send_chain substitute_chain_with values
  end

  alias evaluate_with substitute_and_send_chain_with

  # Call this method after calling new_chain to perform error checking and replace :placeholders with values.
  # @chain is not modified.
  # @return [Array] Modified chain
  def substitute_chain_with(values)
    values = [values] unless values.instance_of?(Array)

    placeholder_count = @chain.flatten.count { |x| x == :placeholder }
    if values.length != placeholder_count
      abort "with_values error: number of values (#{values.length}) does not match the number of placeholders (#{placeholder_count})"
    end

    eval_chain @chain, values
  end

  private

  # Replaces :placeholders with values
  # Does not use any external state
  # @return modified chain
  def eval_chain(chain, values)
    chain.map do |c|
      case c
      when :placeholder
        values.shift
      when Array
        eval_chain c, values
      else
        c
      end
    end
  end
end
