<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\PayrollDetailRequest;
use App\Models\PayrollDetail;
use Illuminate\Http\Response;

class PayrollDetailController extends Controller
{
    public function store(PayrollDetailRequest $request)
    {
        $detail = PayrollDetail::create($request->validated());
        return response()->json($detail, Response::HTTP_CREATED);
    }

    public function update(PayrollDetailRequest $request, PayrollDetail $detail)
    {
        $detail->update($request->validated());
        return response()->json($detail);
    }

    public function destroy(PayrollDetail $detail)
    {
        $detail->delete();
        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}