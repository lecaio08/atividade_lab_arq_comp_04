// FSM de controle da versao refinada do multiplicador (Patterson & Hennessy)
module multiplier_control #(
    parameter int WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    // Interface com o usuario
    input  logic start,
    output logic done,

    // Interface com o datapath
    output logic load,        // Carrega operandos iniciais
    output logic compute_en   // Executa iteracao (add condicional + shift)
);

    // Definicao dos estados da FSM
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        LOAD    = 2'b01,
        COMPUTE = 2'b10,
        DONE    = 2'b11
    } state_t;

    state_t state, next_state;
    logic [$clog2(WIDTH)-1:0] count;

    // Registrador de estado e contador de ciclos
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            count <= '0;
        end else begin
            state <= next_state;
            if (state == COMPUTE)
                count <= count + 1'b1;
            else
                count <= '0;
        end
    end

    // Logica combinacional de proximo estado e saidas
    always_comb begin
        next_state = state;
        load       = 1'b0;
        compute_en = 1'b0;
        done       = 1'b0;

        case (state)
            IDLE: begin
                if (start) next_state = LOAD;
            end

            LOAD: begin
                load       = 1'b1;
                next_state = COMPUTE;
            end

            COMPUTE: begin
                compute_en = 1'b1;
                if (count == WIDTH - 1)
                    next_state = DONE;
            end

            DONE: begin
                done = 1'b1;
                if (!start) next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
