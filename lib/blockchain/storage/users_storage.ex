defmodule StatsCollector.Storage.UsersStorage do
  alias StatsCollector.Storage.MongoAdapter
  alias StatsCollector.MongoUtils
  alias StatsCollector.Config

  def active_users_pipeline(start_date, end_date) do
    group_by_xpub = %{
			"$group" => %{
			    "_id" => "$ext_pub_key_sha256"
			}
		}

    lookup = %{
      "$lookup" => %{
        "from" => "user_xpub_binding",
        "localField" => "_id",
        "foreignField" => "xpub_sha256",
        "as" => "xpub_data"
      }
    }

    unwind = %{
      "$unwind" => "$xpub_data"
    }

    group_ids = %{
      "$group" => %{
        "_id" => nil,
        "ids" => %{"$addToSet" => "$xpub_data.user_id"}
      }
    }

    [match_by_period(start_date, end_date), group_by_xpub, lookup, unwind, group_ids]
  end

  def active_users_pipeline(start_date, end_date, :merchant_v2) do
		project_id = %{
			"$project" => %{
			    "_id" => 0,
			    "invoice_id" => 1
			}
		}

		lookup = %{
			"$lookup" => %{
			    "from" => "invoices",
			    "localField" => "invoice_id",
			    "foreignField" => "_id",
			    "as" => "invoices"
			}
		}

		project = %{
			"$project" => %{
			    "user_id" => %{"$arrayElemAt" => ["$invoices.user_id", 0]},
			    "ver" => %{"$arrayElemAt" => ["$invoices.ver", 0]},
			}
		}

		match_ver = %{
			"$match" => %{
			    "ver" => 2
			}
		}

    group = %{
      "$group" => %{
        "_id" => nil,
        "ids" => %{"$addToSet" => "$user_id"}
      }
    }

    [match_by_period(start_date, end_date), project_id, lookup, project, match_ver, group]
  end

  def match_by_period(start_date, end_date) do
    %{
      "$match" => %{
        "$and" => [
          %{"created" => %{"$gte" => start_date}},
          %{"created" => %{"$lt" => end_date}},
        ]
      }
    }
  end

  def filter_and_count_regular_users(user_ids) do
    match = %{
      "$and" => [
        %{"email_confirmed" => %{"$eq" => true}},
        %{"merchant_wallet.main" => %{"$eq" => nil}},
        %{"default_wallet.main" => %{"$ne" => nil}},
        %{"status" => %{"$eq" => "active"}},
        %{"id" => %{"$in" => user_ids}},
      ]
    }

    MongoAdapter.count(Config.membership_mongo_pid(), "usermodels", apply_filter_test_users(match))
  end

  def filter_and_count_merchant_v2_users(user_ids) do
    match = %{
      "$and" => [
        %{"email_confirmed" => %{"$eq" => true}},
        %{"merchant_wallet.main" => %{"$eq" => nil}},
        %{"default_wallet.main" => %{"$eq" => nil}},
        %{"status" => %{"$eq" => "active"}},
        %{"id" => %{"$in" => user_ids}},
      ]
    }

    MongoAdapter.count(Config.membership_mongo_pid(), "usermodels", apply_filter_test_users(match))
  end

  def filter_and_count_merchant_v3_users(user_ids) do
    match = %{
      "$and" => [
        %{"email_confirmed" => %{"$eq" => true}},
        %{"merchant_wallet.main" => %{"$ne" => nil}},
        %{"status" => %{"$eq" => "active"}},
        %{"id" => %{"$in" => user_ids}},
      ]
    }

    MongoAdapter.count(Config.membership_mongo_pid(), "usermodels", apply_filter_test_users(match))
  end

  defp apply_filter_test_users(match \\ %{}) do
    is_test_filter = %{"isTest" => %{"$ne" => true}}
    email_filter = %{"email" => %{"$not" => MongoUtils.ignored_emails_regex()}}
    match_list = Map.get(match, "$and", [])

    put_in(match, ["$and"], [is_test_filter | match_list] ++ [email_filter])
  end

  def get_test_users_ids() do
    match = %{
      "$match" => apply_filter_test_users()
    }

    group = %{
      "$group" => %{
        "_id" => nil,
        "ids" => %{"$push" => "$id"}
      }
    }

    projection = %{
      "$project" => %{
        "_id" => 0,
        "ids" => 1
      }
    }

    Config.membership_mongo_pid()
    |> MongoAdapter.aggregate("usermodels", [match, group, projection])
    |> Enum.at(0, %{})
    |> Map.get("ids", [])
  end
end
