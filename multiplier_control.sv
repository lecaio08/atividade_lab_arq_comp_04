module multiplier_control (
    input  logic clk,
    input  logic rst_n,
    // Interface com o usuário
    input  logic start,
    output logic done,
    // Interface com o datapath
    output logic load,        // Carrega operandos iniciais
    output logic compute_en   // Executa uma iteração (add condicional + shift)
);

    // -------------------------------------------------------------------
    // 1. Definição dos Estados (Codificação One-Hot com atributo de síntese)
    // -------------------------------------------------------------------
    typedef enum logic [3:0] {
        ST_IDLE    = 4'b0001,
        ST_LOAD    = 4'b0010,
        ST_COMPUTE = 4'b0100,
        ST_DONE    = 4'b1000
    } state_t;

    (* fsm_encoding = "one_hot" *) state_t current_state, next_state;

    // -------------------------------------------------------------------
    // 2. Contador Interno de Iterações (0 a 31)
    // -------------------------------------------------------------------
    logic [4:0] count;
    logic       count_max;

    // Flag limpa para indicar a última iteração do multiplicador (32ª iteração)
    assign count_max = (count == 5'd31);

    // -------------------------------------------------------------------
    // 3. Lógica Sequencial: Registrador de Estado e Contador
    // -------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= ST_IDLE;
            count         <= '0;
        end else begin
            current_state <= next_state;

            if (current_state == ST_LOAD) begin
                count <= '0;
            end else if (current_state == ST_COMPUTE) begin
                count <= count + 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------
    // 4. Lógica Combinacional: Próximo Estado e Saídas de Moore
    // -------------------------------------------------------------------
    always_comb begin
        // Valores default para prevenção rigorosa de latches inferidos
        next_state  = current_state;
        load        = 1'b0;
        compute_en  = 1'b0;
        done        = 1'b0;

        case (current_state)
            ST_IDLE: begin
                if (start) begin
                    next_state = ST_LOAD;
                end
            end

            ST_LOAD: begin
                load       = 1'b1;
                next_state = ST_COMPUTE;
            end

            ST_COMPUTE: begin
                compute_en = 1'b1;
                if (count_max) begin
                    next_state = ST_DONE;
                end
            end

            ST_DONE: begin
                done = 1'b1;
                if (!start) begin
                    next_state = ST_IDLE;
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule
