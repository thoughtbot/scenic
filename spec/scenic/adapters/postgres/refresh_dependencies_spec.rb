require "spec_helper"

module Scenic
  module Adapters
    describe Postgres::RefreshDependencies, :db do
      it "refreshes dependecies in the correct order" do
        adapter = Postgres.new

        adapter.create_materialized_view(
          "first",
          "SELECT text 'hi' AS greeting",
        )

        adapter.create_materialized_view(
          "second",
          "SELECT * from first",
        )

        adapter.create_materialized_view(
          "third",
          "SELECT * from first UNION SELECT * from second",
        )

        adapter.create_materialized_view(
          "fourth",
          "SELECT * from third",
        )

        expect(adapter).to receive(:refresh_materialized_view).
          with("public.first").ordered

        expect(adapter).to receive(:refresh_materialized_view).
          with("public.second").ordered

        expect(adapter).to receive(:refresh_materialized_view).
          with("public.third").ordered

        described_class.call(:fourth, adapter, ActiveRecord::Base.connection)
      end
    end
  end
end
