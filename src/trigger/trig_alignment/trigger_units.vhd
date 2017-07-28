----------------------------------------------------------------------------------
-- Company:        University
-- Engineer:       John Smith   (john.smith@email.com)
--
-- Produce Trigger units from VFAT trigger inputs
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;

entity trigger_units is
port(

    -- sbits
    vfat_sof_p     : in std_logic_vector (23 downto 0);
    vfat_sof_n     : in std_logic_vector (23 downto 0);

    vfat_sbits_p     : in std_logic_vector (191 downto 0);
    vfat_sbits_n     : in std_logic_vector (191 downto 0);

    trigger_units_o : out trigger_unit_array_t (23 downto 0)
);
end trigger_units;

architecture Behavioral of trigger_units is

begin

    trig_unit_loop : for I in 0 to (23) generate
    begin
    trigger_units_o(I).trig_data_p      <= vfat_sbits_p ((I+1)*8-1 downto I*8);
    trigger_units_o(I).trig_data_n      <= vfat_sbits_n ((I+1)*8-1 downto I*8);
    trigger_units_o(I).start_of_frame_p <= vfat_sof_p(I);
    trigger_units_o(I).start_of_frame_n <= vfat_sof_n(I);
    end generate;

end Behavioral;
