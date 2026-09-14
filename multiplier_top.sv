// Wrapper Top-Level parametrizado da unidade multiplicadora
module multiplier_top #(
    parameter int WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 rst_n,

    input  logic                 start,
    input  logic [WIDTH-1:0]     multiplicand_in,
    input  logic [WIDTH-1:0]     multiplier_in,

    output logic [(2*WIDTH)-1:0] product,
    output logic                 done
);

    // Sinais de interconexao
    logic load;
    logic compute_en;

    // Datapath
    multiplier_datapath #(.WIDTH(WIDTH)) datapath (
        .clk             (clk),
        .rst_n           (rst_n),
        .multiplicand_in (multiplicand_in),
        .multiplier_in   (multiplier_in),
        .load            (load),
        .compute_en      (compute_en),
        .product         (product)
    );

    // Unidade de Controle (FSM)
    multiplier_control #(.WIDTH(WIDTH)) control (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .done       (done),
        .load       (load),
        .compute_en (compute_en)
    );

endmodule
