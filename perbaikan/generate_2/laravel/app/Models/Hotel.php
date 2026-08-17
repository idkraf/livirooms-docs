<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphToMany;

class Hotel extends Model
{
    protected $table = 'hotels';

    protected $fillable = [
        'property_id',
        'star_rating',
        'open_year',
        'check_in_time',
        'check_out_time',
        'deposit_amount',
    ];

    protected $casts = [
        'star_rating' => 'integer',
        'open_year' => 'integer',
        'deposit_amount' => 'decimal:2',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function policy(): HasOne
    {
        return $this->hasOne(HotelPolicy::class);
    }

    public function scoreComponents(): HasMany
    {
        return $this->hasMany(HotelScoreComponent::class);
    }

    public function transportPoints(): HasMany
    {
        return $this->hasMany(HotelTransportPoint::class)->orderBy('sort_order');
    }

    public function faqs(): HasMany
    {
        return $this->hasMany(HotelFaq::class)->orderBy('sort_order');
    }

    public function reviewQuotes(): HasMany
    {
        return $this->hasMany(HotelReviewQuote::class)->orderBy('sort_order');
    }

    public function roomTypes(): HasMany
    {
        return $this->hasMany(RoomType::class);
    }

    public function activeRoomTypes(): HasMany
    {
        return $this->hasMany(RoomType::class)->where('is_active', true);
    }

    public function media(): MorphMany
    {
        return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
    }

    public function facilities(): MorphToMany
    {
        return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
            ->withPivot('is_available', 'badge', 'sort_order')
            ->orderBy('sort_order');
    }

    public function getPriceFromAttribute(): ?float
    {
        $cheapest = $this->activeRoomTypes()->orderBy('base_price')->first();

        return $cheapest ? (float) $cheapest->base_price : null;
    }

    public function getPriceOriginalAttribute(): ?float
    {
        $cheapest = $this->activeRoomTypes()->first();

        return $cheapest?->price_original !== null ? (float) $cheapest->price_original : null;
    }

    public function getOverallScoreAttribute(): ?float
    {
        if (empty($this->score)) {
            return null;
        }

        return $this->score['basic'] ?? null;
    }
}
