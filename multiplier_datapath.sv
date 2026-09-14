// Datapath refinado com multiplicador e deslocamento combinados
module multiplier_datapath #(
    parameter int WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 rst_n,

    // Entradas de dados
    input  logic [WIDTH-1:0]     multiplicand_in,
    input  logic [WIDTH-1:0]     multiplier_in,

    // Sinais de controle vindos da FSM
    input  logic                 load,
    input  logic                 compute_en,

    // Saida do resultado
    output logic [(2*WIDTH)-1:0] product
);

    // Registradores internos
    logic [WIDTH-1:0]     multiplicand_reg;
    logic [(2*WIDTH)-1:0] product_reg;

    // Sinais da ALU e Mux
    logic [WIDTH-1:0] alu_sum;
    logic             alu_carry;
    logic [WIDTH:0]   shift_in;

    // ALU de 32 bits conectada a metade superior do registrador do produto
    alu_32 #(.WIDTH(WIDTH)) alu_inst (
        .a         (product_reg[(2*WIDTH)-1 : WIDTH]),
        .b         (multiplicand_reg),
        .sum       (alu_sum),
        .carry_out (alu_carry)
    );

    // Mux condicional: se LSB e 1 soma ALU + Carry, se 0 repassa a metade superior
    assign shift_in = product_reg[0] ? {alu_carry, alu_sum} : {1'b0, product_reg[(2*WIDTH)-1 : WIDTH]};
    assign product  = product_reg;

    // Atualizacao dos registradores
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand_reg <= '0;
            product_reg      <= '0;
        end else if (load) begin
            multiplicand_reg <= multiplicand_in;
            product_reg      <= {{WIDTH{1'b0}}, multiplier_in};
        end else if (compute_en) begin
            // Executa o deslocamento a direita de 65 bits em 1 ciclo
            product_reg <= {shift_in, product_reg[WIDTH-1 : 1]};
        end
    end

endmodule
