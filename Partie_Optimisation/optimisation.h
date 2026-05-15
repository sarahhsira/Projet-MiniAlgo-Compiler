#ifndef OPTIMISATION_H
#define OPTIMISATION_H

#include "quad.h"

void optimiser_propagation_copie();
void propagation_expression();
void optimiser_expressions_redondantes();
void optimiser_simplification_algebrique();
void optimiser_code_mort();
void optimiser_tout(void);
#endif