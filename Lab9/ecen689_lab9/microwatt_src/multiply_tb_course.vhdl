-- ECEN 689 course testbench for Microwatt's multiply unit.
-- Self-checking, no external libraries. Drives directed test vectors through
-- the 3-stage pipelined multiplier and asserts every result.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity multiply_tb_course is
end entity multiply_tb_course;

architecture behave of multiply_tb_course is
    constant CLK_PERIOD : time := 10 ns;
    signal clk   : std_ulogic := '0';
    signal m_in  : MultiplyInputType := MultiplyInputInit;
    signal m_out : MultiplyOutputType;
    signal done  : boolean := false;
begin
    mult_0: entity work.multiply
        port map (clk => clk, m_in => m_in, m_out => m_out);

    clk_process: process
    begin
        while not done loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim: process
        type vec_t is record
            a, b    : integer;
            expect  : integer;
        end record;
        type vec_array_t is array (natural range <>) of vec_t;
        constant vectors : vec_array_t := (
            (a => 5,     b => 7,      expect => 35),
            (a => 0,     b => 12345,  expect => 0),
            (a => 1,     b => 99999,  expect => 99999),
            (a => 1000,  b => 1000,   expect => 1000000),
            (a => 256,   b => 256,    expect => 65536),
            (a => 3,     b => -4,     expect => -12),
            (a => -6,    b => -7,     expect => 42)
        );
        variable got : signed(127 downto 0);
        variable errors : natural := 0;
    begin
        wait for CLK_PERIOD;  -- settle

        for i in vectors'range loop
            -- drive one multiply request
            m_in.valid     <= '1';
            m_in.data1     <= std_ulogic_vector(to_signed(vectors(i).a, 64));
            m_in.data2     <= std_ulogic_vector(to_signed(vectors(i).b, 64));
            m_in.addend    <= (others => '0');
            m_in.is_signed <= '1';
            m_in.subtract  <= '0';
            wait for CLK_PERIOD;
            m_in.valid     <= '0';

            -- wait for the pipeline to answer
            wait for CLK_PERIOD;
            while m_out.valid /= '1' loop
                wait for CLK_PERIOD;
            end loop;

            got := signed(m_out.result);
            assert to_integer(got(63 downto 0)) = vectors(i).expect
                report "MULTIPLY FAIL: " & integer'image(vectors(i).a) & " * "
                       & integer'image(vectors(i).b) & " = "
                       & integer'image(to_integer(got(63 downto 0)))
                       & "  (expected " & integer'image(vectors(i).expect) & ")"
                severity error;
            if to_integer(got(63 downto 0)) /= vectors(i).expect then
                errors := errors + 1;
            end if;
            wait for CLK_PERIOD;
        end loop;

        if errors = 0 then
            report "ALL MULTIPLY TESTS PASSED (" & integer'image(vectors'length) & " vectors)" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity failure;
        end if;
        done <= true;
        wait;
    end process;
end architecture behave;
