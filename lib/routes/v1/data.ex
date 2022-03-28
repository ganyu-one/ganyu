defmodule Ganyu.Router.V1.Data do
  @moduledoc """
  `Ganyu.Data` is a module that provides a data source for Ganyu.
  """

  @proxy_path Application.get_env(:ganyu, :proxy_path, "https://pximg.pxseu.com")

  @spec select_random :: %{id: String.t(), url: String.t()}
  def select_random do
    # "#{@proxy_path}/#{}"
    path = data() |> Enum.random()

    id =
      path
      |> String.split("/")
      |> List.last()
      |> String.split("_")
      |> List.first()

    %{
      url: path,
      id: id
    }
  end

  @spec data_includes(String.t()) :: boolean
  def data_includes(path) do
    path in data()
  end

  @spec data :: [String.t()]
  def data do
    [
      "img-original/img/2021/01/19/00/00/02/87147685_p0.png",
      "img-original/img/2021/01/20/00/00/27/87168184_p0.jpg",
      "img-original/img/2021/01/28/20/11/42/87360333_p0.png",
      "img-original/img/2021/02/23/09/03/15/87985028_p0.png",
      "img-original/img/2021/04/02/02/13/06/88868181_p0.jpg",
      "img-original/img/2021/04/07/19/25/43/88997747_p0.jpg",
      "img-original/img/2021/05/23/20/14/48/90045253_p0.png",
      "img-original/img/2021/06/06/17/21/02/90367181_p0.png",
      "img-original/img/2021/06/15/00/00/06/90561009_p0.jpg",
      "img-original/img/2021/06/29/00/13/34/90881391_p0.png",
      "img-original/img/2021/07/21/08/03/05/91388514_p0.png",
      "img-original/img/2021/08/07/07/37/32/91780715_p0.png",
      "img-original/img/2021/08/10/00/03/17/91856371_p0.jpg",
      "img-original/img/2021/08/21/06/14/38/92140573_p0.png",
      "img-original/img/2021/08/21/11/10/05/92143634_p0.png",
      "img-original/img/2021/08/24/10/30/08/92222865_p0.png",
      "img-original/img/2021/09/12/13/34/17/92689587_p0.jpg",
      "img-original/img/2021/09/20/15/51/15/92884804_p0.png",
      "img-original/img/2021/09/22/23/20/00/92941979_p0.png",
      "img-original/img/2021/10/06/16/45/58/93261557_p0.jpg",
      "img-original/img/2021/10/10/00/00/02/93336306_p0.jpg",
      "img-original/img/2021/10/10/18/32/21/93354528_p0.jpg",
      "img-original/img/2021/10/24/18/30/48/93655526_p0.jpg",
      "img-original/img/2021/10/26/16/08/32/93696488_p0.jpg",
      "img-original/img/2021/10/28/23/37/55/93744862_p0.jpg",
      "img-original/img/2021/10/31/00/02/44/93791448_p0.jpg",
      "img-original/img/2021/10/31/00/17/35/93792496_p0.jpg",
      "img-original/img/2021/10/31/08/06/32/93800581_p0.png",
      "img-original/img/2021/11/04/23/32/44/93920392_p0.jpg",
      "img-original/img/2021/11/07/21/39/15/93986018_p0.png",
      "img-original/img/2021/11/13/06/21/19/94097039_p0.png",
      "img-original/img/2021/11/18/14/06/59/94208942_p0.jpg",
      "img-original/img/2021/11/20/14/46/20/94249924_p0.png",
      "img-original/img/2021/11/28/00/00/06/94416462_p0.jpg",
      "img-original/img/2021/12/02/00/09/59/94505426_p0.jpg",
      "img-original/img/2021/12/02/07/10/44/94510053_p0.png",
      "img-original/img/2021/12/02/09/45/11/94028092_p0.png",
      "img-original/img/2021/12/03/20/59/34/94539388_p0.png",
      "img-original/img/2021/12/05/23/05/53/94592968_p0.jpg",
      "img-original/img/2021/12/06/13/13/58/94603313_p0.png",
      "img-original/img/2021/12/12/00/00/04/94717529_p0.jpg",
      "img-original/img/2021/12/12/12/53/47/94727702_p0.jpg",
      "img-original/img/2021/12/22/17/28/10/94935939_p0.jpg",
      "img-original/img/2021/12/25/01/25/25/94995312_p0.jpg",
      "img-original/img/2021/12/25/13/09/57/95005930_p0.jpg",
      "img-original/img/2021/12/30/22/17/15/95142164_p0.jpg",
      "img-original/img/2021/12/31/01/51/41/95148804_p0.jpg",
      "img-original/img/2022/01/03/13/44/01/95263945_p0.png",
      "img-original/img/2022/01/03/17/31/25/95268504_p0.jpg",
      "img-original/img/2022/01/05/00/00/03/95304565_p0.jpg",
      "img-original/img/2022/01/08/15/04/41/95381757_p0.jpg",
      "img-original/img/2022/01/09/21/47/28/95416112_p0.jpg",
      "img-original/img/2022/01/10/01/32/53/95422939_p0.png",
      "img-original/img/2022/01/17/20/11/12/95593063_p0.jpg",
      "img-original/img/2022/01/18/20/40/41/95614410_p0.jpg",
      "img-original/img/2022/01/20/00/03/24/95639589_p0.jpg",
      "img-original/img/2022/01/22/23/30/16/95703978_p0.jpg",
      "img-original/img/2022/01/24/14/13/32/95743215_p0.jpg",
      "img-original/img/2022/01/25/21/13/04/95771515_p0.png",
      "img-original/img/2022/01/26/10/45/20/95782868_p0.jpg",
      "img-original/img/2022/01/26/11/14/44/95783148_p0.jpg",
      "img-original/img/2022/01/26/18/31/05/95788805_p0.png",
      "img-original/img/2022/01/28/23/39/23/95838216_p0.jpg",
      "img-original/img/2022/01/31/00/00/27/95890328_p0.jpg",
      "img-original/img/2022/02/03/18/00/00/95972192_p0.png",
      "img-original/img/2022/02/04/05/43/14/95986669_p0.png",
      "img-original/img/2022/02/04/23/03/31/96002216_p0.png",
      "img-original/img/2022/02/05/22/46/01/95914102_p0.png",
      "img-original/img/2022/02/08/14/09/32/96061677_p0.jpg",
      "img-original/img/2022/02/08/22/32/48/96099896_p0.png",
      "img-original/img/2022/02/10/01/00/13/96125154_p0.jpg",
      "img-original/img/2022/02/12/09/47/58/96177680_p0.png",
      "img-original/img/2022/02/12/13/04/34/96180666_p0.png",
      "img-original/img/2022/02/13/12/01/01/96206357_p0.png",
      "img-original/img/2022/02/13/18/34/02/96214903_p0.png",
      "img-original/img/2022/02/14/00/08/21/96226913_p0.png",
      "img-original/img/2022/02/14/15/09/56/96242608_p0.png",
      "img-original/img/2022/02/15/01/09/15/96263945_p0.jpg",
      "img-original/img/2022/02/15/13/53/38/96273364_p0.jpg",
      "img-original/img/2022/02/15/15/10/23/96274318_p0.jpg",
      "img-original/img/2022/02/16/02/33/55/96289568_p0.png",
      "img-original/img/2022/02/16/03/17/26/96290049_p0.jpg",
      "img-original/img/2022/02/16/17/40/58/96298836_p0.png",
      "img-original/img/2022/02/18/00/02/11/96329502_p0.jpg",
      "img-original/img/2022/02/18/15/41/13/96339916_p0.jpg",
      "img-original/img/2022/02/18/22/45/21/96348887_p0.jpg",
      "img-original/img/2022/02/19/09/34/06/96358221_p0.png",
      "img-original/img/2022/02/20/00/39/47/96377631_p0.jpg",
      "img-original/img/2022/02/20/21/39/25/96376304_p0.png",
      "img-original/img/2022/02/22/00/33/11/96427433_p0.png",
      "img-original/img/2022/02/24/00/00/13/96477300_p0.png",
      "img-original/img/2022/02/25/22/37/42/96517207_p0.jpg",
      "img-original/img/2022/03/01/19/20/14/87768879_p0.jpg",
      "img-original/img/2022/03/05/16/59/51/96694327_p0.jpg",
      "img-original/img/2022/03/05/22/45/46/96703204_p0.jpg",
      "img-original/img/2022/03/07/01/41/01/96735660_p0.png",
      "img-original/img/2022/03/09/14/28/24/96787040_p0.png",
      "img-original/img/2022/03/10/10/12/53/96807305_p0.jpg",
      "img-original/img/2022/03/11/16/24/12/96832488_p0.jpg",
      "img-original/img/2022/03/12/02/05/33/96845524_p0.jpg",
      "img-original/img/2022/03/12/14/30/00/96853930_p0.jpg",
      "img-original/img/2022/03/13/14/05/27/96878796_p0.jpg",
      "img-original/img/2022/03/13/18/55/16/96885099_p0.png",
      "img-original/img/2022/03/15/18/22/42/96894812_p0.jpg",
      "img-original/img/2022/02/04/01/48/21/95984369_p0.jpg",
      "img-original/img/2022/02/11/16/21/17/96158517_p0.jpg",
      "img-original/img/2021/11/01/22/31/26/93855247_p0.jpg",
      "img-original/img/2022/02/03/02/37/57/95961930_p0.jpg",
      "img-original/img/2022/01/29/00/00/03/95838766_p0.jpg",
      "img-original/img/2022/01/22/00/01/18/95680217_p0.jpg",
      "img-original/img/2021/10/01/12/27/15/93140676_p0.png",
    ]
    |> Enum.map(fn value -> "#{@proxy_path}/#{value}" end)
  end
end
