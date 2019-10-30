defmodule BlockScoutWeb.ChainView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.LayoutView

  # NOTE: The market_cap functions that were here have been removed in the loomchain fork because
  # the market cap section has been removed from apps\block_scout_web\lib\block_scout_web\templates\chain\show.html.eex
end
