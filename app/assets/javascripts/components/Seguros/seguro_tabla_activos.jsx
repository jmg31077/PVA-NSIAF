class SeguroTablaActivos extends React.Component {
  tabla_desglose(cantidad) {
      const activos = this.props.activos.map((activo, i) => {
        return (
          <tr key = {i}>
            <td className="text-center">
              { i + 1 }
            </td>
            <td className="text-center">
              { activo.code }
            </td>
            <td>
              { activo.description }
            </td>
            <td>
              { activo.cuenta }
            </td>
            <td className = "number">
              { activo.precio }
            </td>
          </tr>
        )
      });

      const sumatoria = (
            <tr key>
              <td colSpan='3'>
              </td>
              <td className = "text-right">
                <strong>
                  TOTAL:
                </strong>
              </td>
              <td className = "number">
                <strong>
                  {this.props.sumatoria}
              </strong>
              </td>
            </tr>
      );

    return(
      <table className="table table-bordered table-striped table-hover table-condensed">
        <thead>
          <tr>
            <th className="text-center">
              <strong className="badge" title="Total">
                {cantidad}
              </strong>
            </th>
            <th className="text-center">Código</th>
            <th className="text-center">Descripción</th>
            <th className="text-center">Cuenta</th>
            <th className="text-center">Precio</th>
          </tr>
        </thead>
        <tbody>
          { activos }
          { sumatoria }
        </tbody>
      </table>
    );
  }

  tabla_resumen(){
    const cuentas = this.props.resumen.map((cuenta, i) => {
      return (
        <tr key = {i}>
          <td className="text-center">
            { i + 1 }
          </td>
          <td>
            { cuenta.nombre }
          </td>
          <td className = "number">
            { cuenta.sumatoria }
          </td>
        </tr>
      )
    });

    const sumatoria_resumen = (
          <tr key>
            <td>
            </td>
            <td className = "text-right">
              <strong>
                TOTAL:
              </strong>
            </td>
            <td className = "number">
              <strong>
                {this.props.sumatoria_resumen}
            </strong>
            </td>
          </tr>
    );

    return(
      <table className="table table-bordered table-striped table-hover table-condensed">
        <thead>
          <tr>
            <th>
            </th>
            <th className="text-center">Cuenta</th>
            <th className="text-center">Monto</th>
          </tr>
        </thead>
        <tbody>
          { cuentas }
          { sumatoria_resumen }
        </tbody>
      </table>
    );
  }

  render() {
    const cantidad_activos  = this.props.activos.length;
    if(cantidad_activos > 0){
      return (
        <div role="tabpanel">
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item active">
              <a aria-controls="resumen" aria-expanded="true" className="nav-link active" data-toggle="tab" href="#resumen" id="resumen-tab" role="tab">Resumen</a>
            </li>
            <li className="nav-item">
              <a aria-controls="desglose" aria-expanded="false" className="nav-link" data-toggle="tab" href="#desglose" id="desglose-tab" role="tab">Desglose</a>
            </li>
          </ul>
          <div className="tab-content" id="myTabContent">
            <div aria-expanded="true" aria-labelledby="resumen-tab" className="tab-pane fade active in" id="resumen" role="tabpanel">
              {this.tabla_resumen()}
            </div>
            <div aria-expanded="false" aria-labelledby="desglose-tab" className="tab-pane fade" id="desglose" role="tabpanel">
              {this.tabla_desglose(cantidad_activos)}
            </div>
          </div>
        </div>
      );
    }
    else {
      return(
        <div>
        </div>
      );
    }
  }
}
