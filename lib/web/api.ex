defmodule Web.API do
  use Plug.Router
  use Plug.ErrorHandler

  alias DistributedKv.BucketSupervisor
  alias DistributedKv.Bucket

  plug Plug.Logger
  plug :put_req_header, {"accept", "application/json"}
  plug :put_req_header, {"content-type", "application/json"}
  plug :match
  plug :dispatch

  get "/:bucket/:key" do
    value = bucket
    |> String.to_atom # Don't do this at home
    |> BucketSupervisor.find_or_start_bucket!
    |> Bucket.get(key)

    send_resp(conn, 200, to_json(value))
  end

  put "/:bucket/:key" do
    {conn, value} = from_json(conn)

    bucket
    |> String.to_atom # Don't do this at home
    |> BucketSupervisor.find_or_start_bucket!
    |> Bucket.set(key, value)

    send_resp(conn, 200, to_json(%{status: :ok}))
  end

  match _ do
    send_resp(conn, 404, to_json(%{error: "Dafuq are you doing?"}))
  end

  defp put_req_header(conn, {key, value}) do
    Plug.Conn.put_resp_header(conn, key, value)
  end

  defp to_json(value), do: Poison.encode! value

  defp from_json(conn) do
    {:ok, body, conn} = read_body(conn)
    {conn, Poison.decode!(body)}
  end
end
