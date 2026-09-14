// ALU parametrizada com bit-growth automatico para o carry-out
module alu_32 #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum,
    output logic             carry_out
);
    // O contexto de atribuicao estendido (LHS com WIDTH+1 bits)
    // lida com o bit de carry nativamente sem concatencao de zeros.
    assign {carry_out, sum} = a + b;
endmodule
