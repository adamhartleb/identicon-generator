defmodule Identicon do
  import Identicon.Image

  def main(input) do
    input 
    |> hash_input
    |> pick_color
    |> create_grid
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def pick_color(image) do
    [r, g, b | _list] = image.hex
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def create_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_rows/1)
      |> List.flatten
      |> Enum.with_index
      |> Enum.filter(fn({x, _index}) ->
          rem(x, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  def mirror_rows(chunked_hex) do
    [first, second | _tail] =  chunked_hex
    chunked_hex ++ [second, first]
  end
  
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("results/#{input}.png", image)
  end
end
