defmodule CercleApi.Mailer do
  def deliver(email) do
    Mailman.deliver(email, config)
  end

  def config do
    %Mailman.Context{
     composer: %Mailman.EexComposeConfig{}
    }
  end
end
